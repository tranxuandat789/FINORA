using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.DTOs.Requests;
using FinanceAPI.DTOs.Responses;
using FinanceAPI.Models;
using FinanceAPI.Models.Enums;
using FinanceAPI.Repositories.Interfaces;
using FinanceAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace FinanceAPI.Services.Implementations
{
    public class TransactionService : ITransactionService
    {
        private readonly ITransactionRepository _transactionRepository;
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _httpClientFactory;

        public TransactionService(
            ITransactionRepository transactionRepository,
            AppDbContext context,
            IConfiguration configuration,
            IHttpClientFactory httpClientFactory)
        {
            _transactionRepository = transactionRepository;
            _context = context;
            _configuration = configuration;
            _httpClientFactory = httpClientFactory;
        }

        public async Task<IEnumerable<TransactionResponse>> GetTransactionsAsync(Guid userId)
        {
            var transactions = await _transactionRepository.GetTransactionsByUserIdAsync(userId);
            return transactions.Select(MapToResponse);
        }

        public async Task<TransactionResponse> CreateTransactionAsync(CreateTransactionRequest request, Guid userId)
        {
            // Verify wallet
            Wallet wallet;
            if (request.WalletId == Guid.Empty)
            {
                wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.UserId == userId && !w.IsDeleted);
                if (wallet == null) throw new Exception("Không tìm thấy ví mặc định.");
                request.WalletId = wallet.Id;
            }
            else
            {
                wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId && w.UserId == userId && !w.IsDeleted);
                if (wallet == null) throw new Exception("Ví không tồn tại hoặc không thuộc quyền sở hữu.");
            }

            // Verify category
            var category = await _context.Categories.FirstOrDefaultAsync(c => c.Id == request.CategoryId && (c.UserId == null || c.UserId == userId) && !c.IsDeleted);
            if (category == null) throw new Exception("Danh mục không tồn tại.");

            // Ensure category type matches transaction type
            if (category.Type != request.Type) throw new Exception("Loại danh mục không khớp với loại giao dịch.");

            var transaction = new Transaction
            {
                Id = Guid.NewGuid(),
                WalletId = request.WalletId,
                CategoryId = request.CategoryId,
                Type = request.Type,
                Amount = request.Amount,
                Note = request.Note,
                TransactionDate = request.TransactionDate,
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            // Update wallet balance
            if (request.Type == TransactionType.Income)
            {
                wallet.Balance += request.Amount;
            }
            else
            {
                wallet.Balance -= request.Amount;
            }

            _context.Wallets.Update(wallet);

            // This also saves the transaction because we do everything in one DbContext
            await _transactionRepository.CreateTransactionAsync(transaction);

            // Load nav props for response
            transaction.Wallet = wallet;
            transaction.Category = category;

            return MapToResponse(transaction);
        }

        public async Task DeleteTransactionAsync(Guid id, Guid userId)
        {
            var transaction = await _transactionRepository.GetTransactionByIdAsync(id, userId);
            if (transaction == null) throw new Exception("Giao dịch không tồn tại.");

            // Revert wallet balance
            if (transaction.Type == TransactionType.Income)
            {
                transaction.Wallet.Balance -= transaction.Amount;
            }
            else
            {
                transaction.Wallet.Balance += transaction.Amount;
            }

            _context.Wallets.Update(transaction.Wallet);
            await _transactionRepository.DeleteTransactionAsync(transaction);
        }

        public async Task<VoiceAnalysisResponse> AnalyzeVoiceAsync(AnalyzeVoiceRequest request, Guid userId)
        {
            // Fetch all available categories for this user
            var categories = await _context.Categories
                .Where(c => !c.IsDeleted && (c.UserId == null || c.UserId == userId))
                .Select(c => new { c.Id, c.Name, Type = c.Type == TransactionType.Income ? "Thu nhập" : "Chi tiêu" })
                .ToListAsync();

            var categoriesText = string.Join("\n", categories.Select(c => $"- ID: {c.Id} | Name: {c.Name} | Type: {c.Type}"));

            var prompt = $@"
Bạn là trợ lý tài chính thông minh. Hãy phân tích câu sau của người dùng: '{request.Text}'
Dưới đây là danh sách các danh mục khả dụng:
{categoriesText}

Hãy trích xuất thông tin và trả về CHỈ MỘT đối tượng JSON hợp lệ (không kèm markdown) với cấu trúc sau:
{{
  ""amount"": <số tiền (chỉ số, ví dụ 35000), hoặc null nếu không rõ>,
  ""categoryId"": ""<ID danh mục phù hợp nhất, hoặc null>"",
  ""note"": ""<ghi chú ngắn gọn, hoặc null>"",
  ""transactionDate"": ""<ngày giao dịch định dạng yyyy-MM-dd, hoặc null nếu không rõ. Hiện tại là {DateTime.Today:yyyy-MM-dd}>""
}}";

            var apiKey = _configuration["Gemini:ApiKey"];
            if (string.IsNullOrEmpty(apiKey) || apiKey == "")
            {
                // Fallback / Mock logic when API key is missing
                var lowerText = request.Text.ToLower().Trim();

                // Convert text numbers to digits and handle common phrases
                lowerText = lowerText.Replace("một", "1")
                                     .Replace("hai", "2")
                                     .Replace("ba", "3")
                                     .Replace("bốn", "4")
                                     .Replace("năm", "5")
                                     .Replace("sáu", "6")
                                     .Replace("bảy", "7")
                                     .Replace("tám", "8")
                                     .Replace("chín", "9")
                                     .Replace("mười", "10")
                                     .Replace("phẩy", ".");

                long? amount = null;
                Guid? catId = null;
                string note = request.Text;
                DateTime? transactionDate = null;

                // Remove thousand separators: "50.000đ" -> "50000đ", "1.200.000" -> "1200000"
                lowerText = System.Text.RegularExpressions.Regex.Replace(lowerText, @"(?<=\d)[.,](?=\d{3}(?!\d))", "");
                // Do it twice in case of "1.200.000"
                lowerText = System.Text.RegularExpressions.Regex.Replace(lowerText, @"(?<=\d)[.,](?=\d{3}(?!\d))", "");

                // Normalize "1 triệu 9" -> "1.9 triệu", "1 củ rưỡi" -> "1.5 củ"
                lowerText = System.Text.RegularExpressions.Regex.Replace(lowerText, @"(\d+(?:\.\d+)?)\s*(tỏi|triệu|củ|m|lít|loét|lốp|sọi|trăm|nghìn|ngàn|k|chục)\s*rưỡi", "$1.5 $2");
                lowerText = System.Text.RegularExpressions.Regex.Replace(lowerText, @"(\d+)\s*(tỏi|triệu|củ|m|lít|loét|lốp|sọi|trăm|nghìn|ngàn|k|chục)\s*(\d+)", "$1.$3 $2");

                // Try to extract amount with advanced regex for Vietnamese
                // Added (?!\p{L}) to ensure the unit is not part of another word (e.g. 'đ' in 'đi')
                var amountRegex = new System.Text.RegularExpressions.Regex(@"(\d+(?:[.,]\d+)?)(?:\s*(k|nghìn|ngàn|ngan|trăm|triệu|củ|m|tỏi|lít|loét|lốp|sọi|đ|vnd|chục|cành)(?!\p{L}))?", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                var matches = amountRegex.Matches(lowerText);

                System.Text.RegularExpressions.Match bestMatch = null;

                // Prefer match that has a unit
                foreach (System.Text.RegularExpressions.Match match in matches)
                {
                    if (!string.IsNullOrEmpty(match.Groups[2].Value))
                    {
                        bestMatch = match;
                        break;
                    }
                }

                // If no unit found, pick the last number in the sentence (e.g., "ngày 6 tháng 6 hết 100")
                if (bestMatch == null && matches.Count > 0)
                {
                    bestMatch = matches[matches.Count - 1];
                }

                if (bestMatch != null && bestMatch.Success)
                {
                    if (double.TryParse(bestMatch.Groups[1].Value.Replace(",", "."), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var parsedValue))
                    {
                        var unit = bestMatch.Groups[2].Value.ToLower();
                        if (unit == "k" || unit == "nghìn" || unit == "ngàn" || unit == "ngan" || unit == "cành") amount = (long)(parsedValue * 1000);
                        else if (unit == "trăm" || unit == "lít" || unit == "loét" || unit == "lốp" || unit == "sọi") amount = (long)(parsedValue * 100000);
                        else if (unit == "triệu" || unit == "củ" || unit == "m") amount = (long)(parsedValue * 1000000);
                        else if (unit == "tỏi") amount = (long)(parsedValue * 1000000000);
                        else if (unit == "chục") amount = (long)(parsedValue * 10000);
                        else amount = (long)parsedValue;

                        // If no unit but value is < 1000 and > 0, assume user meant thousands (e.g., "ăn 50")
                        if (string.IsNullOrEmpty(unit) && amount < 1000 && amount > 0)
                        {
                            amount = amount * 1000;
                        }
                    }
                }

                // Extract Date
                if (lowerText.Contains("hôm kia")) transactionDate = DateTime.Now.AddDays(-2);
                else if (lowerText.Contains("hôm nọ") || lowerText.Contains("hôm trước")) transactionDate = DateTime.Now.AddDays(-2);
                else if (lowerText.Contains("hôm qua") || lowerText.Contains("tối qua") || lowerText.Contains("đêm qua") || lowerText.Contains("qua") && System.Text.RegularExpressions.Regex.IsMatch(lowerText, @"\bqua\b(?!\s+(mất|đời|khỏi|sông))")) transactionDate = DateTime.Now.AddDays(-1);
                else if (lowerText.Contains("hôm nay") || lowerText.Contains("sáng nay") || lowerText.Contains("chiều nay") || lowerText.Contains("tối nay") || lowerText.Contains("nay") && System.Text.RegularExpressions.Regex.IsMatch(lowerText, @"\bnay\b") || lowerText.Contains("rạng sáng nay") || lowerText.Contains("trưa nay")) transactionDate = DateTime.Now;
                else if (lowerText.Contains("ngày mai") || lowerText.Contains("sáng mai") || lowerText.Contains("tối mai")) transactionDate = DateTime.Now.AddDays(1);
                else if (lowerText.Contains("hôm mốt")) transactionDate = DateTime.Now.AddDays(2);
                else if (lowerText.Contains("mùng 1") || lowerText.Contains("mùng một")) transactionDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                else if (lowerText.Contains("rằm") || lowerText.Contains("ngày rằm")) transactionDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 15);
                else
                {
                    // Try to parse explicit dates like "mùng 6 tháng 6", "ngày 6 tháng 6", "ngày 12/5", "12 tháng 5"
                    var dateRegex = new System.Text.RegularExpressions.Regex(@"(?:ngày|mùng)?\s*(\d{1,2})\s*(?:tháng|/|-)\s*(\d{1,2})(?:\s*(?:năm|/|-)\s*(\d{4}|\d{2}))?", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                    var dateMatch = dateRegex.Match(lowerText);
                    if (dateMatch.Success)
                    {
                        if (int.TryParse(dateMatch.Groups[1].Value, out int day) &&
                            int.TryParse(dateMatch.Groups[2].Value, out int month))
                        {
                            int year = DateTime.Now.Year;
                            if (dateMatch.Groups[3].Success && int.TryParse(dateMatch.Groups[3].Value, out int parsedYear))
                            {
                                year = parsedYear < 100 ? 2000 + parsedYear : parsedYear;
                            }

                            try
                            {
                                transactionDate = new DateTime(year, month, day, DateTime.Now.Hour, DateTime.Now.Minute, DateTime.Now.Second);
                            }
                            catch
                            {
                                // Invalid date (e.g. 31/2), fallback to today
                            }
                        }
                    }
                }

                // Extract Category (Keyword Match)
                var categoryKeywords = new Dictionary<string, List<string>>
                {
                    // CHI TIÊU
                    { "ăn uống", new List<string> { "ăn trưa", "ăn sáng", "ăn tối", "ăn vặt", "ăn đêm", "nhậu", "đi ăn", "phở bò", "phở gà", "bún chả", "bún đậu", "bún đậu mắm tôm", "bún cá", "bún ốc", "bún riêu", "bánh cuốn", "bánh bao", "cháo lòng", "xôi", "cơm rang", "lẩu", "lẩu thái", "lẩu ếch", "lẩu bò", "nướng", "ốc luộc", "nem nướng", "viên chiên", "kfc", "lotteria", "mcdonald", "trà đá", "nhân trần", "nước mía", "trà sữa", "phê la", "highland", "mixue", "bia hơi", "cà phê", "nước ép", "mua rau", "mua thịt", "mua cá", "hải sản", "hoa quả", "trái cây", "bánh kẹo", "sữa chua", "thức ăn", "cơm", "nước" } },
                    { "di chuyển", new List<string> { "đổ xăng", "xăng", "xe ôm", "taxi", "grab", "be", "xanh sm", "xe bus", "gửi xe", "rửa xe", "bơm xe", "thay dầu", "vá xăm", "vá lốp", "bảo dưỡng xe", "vé xe", "bến xe", "vé cầu đường", "bot", "cao tốc", "vé tàu", "vé máy bay", "xe", "đi lại" } },
                    { "mua sắm", new List<string> { "mua sắm", "shopee", "tiki", "lazada", "tiktok shop", "tóp tóp", "chợ", "siêu thị", "winmart", "vinmart", "circle k", "tạp hóa", "đồ gia dụng", "xoong nồi", "bát đĩa", "bột giặt", "nước xả", "nước rửa bát", "giấy vệ sinh", "mua", "quần áo", "váy vóc", "áo phông", "áo sơ mi", "quần jean", "quần âu", "giày thể thao", "dép", "mũ", "kính", "balo", "túi xách", "váy", "áo", "quần", "giày", "trang phục", "cắt tóc", "gội đầu", "làm nail", "làm móng", "spa", "nặn mụn", "mát xa", "massage", "uốn tóc", "nhuộm tóc", "mỹ phẩm", "skincare", "kem chống nắng", "tẩy trang", "sữa rửa mặt", "son", "phấn" } },
                    { "nhà cửa & hóa đơn", new List<string> { "tiền nhà", "tiền trọ", "thuê nhà", "trọ", "bảo vệ", "vệ sinh", "rác", "phí quản lý", "chung cư", "mạng", "internet", "wifi", "truyền hình cáp", "nước lọc", "đổi bình nước", "điện", "nước", "điện thoại" } },
                    { "giải trí", new List<string> { "xem phim", "cgv", "lotte cinema", "bỏng ngô", "netflix", "spotify", "youtube premium", "nạp thẻ", "nạp game", "steam", "bida", "bi-a", "bi da", "karaoke", "hát hò", "pub", "bar", "club", "đi quẩy" } },
                    { "y tế & sức khỏe", new List<string> { "nhà thuốc", "khám bệnh", "mua thuốc", "bệnh viện", "phòng khám", "nha khoa", "lấy cao răng", "nhổ răng", "siêu âm", "xét nghiệm", "viện phí", "long châu", "pharmacity", "thuốc cảm", "thuốc ho" } },
                    { "quan hệ xã hội", new List<string> { "đám cưới", "mừng cưới", "phong bì", "ăn hỏi", "thăm ốm", "đầy tháng", "thôi nôi", "sinh nhật", "mừng tuổi", "lì xì", "quà cáp", "biếu sếp", "quan hệ xã hội" } },
                    { "tâm linh & đồ lễ", new List<string> { "thắp hương", "mua hoa", "tiền vàng", "vàng mã", "đồ lễ", "đi chùa", "dâng sao", "giải hạn", "đám ma", "phúng viếng", "đám giỗ" } },
                    { "giáo dục & con cái", new List<string> { "học phí", "tiền học", "học thêm", "mua sách", "mua vở", "bút", "văn phòng phẩm", "khóa học", "tiếng anh", "toeic", "ielts", "bỉm", "sữa", "đồ chơi cho con", "tiền học cho con" } },
                    { "khác", new List<string> { "khác", "lặt vặt" } },

                    // THU NHẬP
                    { "tiền lương", new List<string> { "lương", "nhận lương", "trả lương" } },
                    { "tiền thưởng", new List<string> { "thưởng", "kpi", "cpi", "thu nhập" } },
                    { "tiền lãi / đầu tư", new List<string> { "tiền lãi", "lãi", "đầu tư", "chứng khoán", "coin", "cổ phiếu" } },
                    { "bán đồ / thanh lý", new List<string> { "bán hàng", "thanh lý", "bán" } },
                    { "được tặng / cho", new List<string> { "người nhà cho", "bố mẹ cho", "lộc", "thu nợ", "đòi nợ", "trúng số", "trúng lô", "trúng đề", "cho", "tặng" } }
                };

                string matchedCategoryName = null;
                foreach (var kvp in categoryKeywords)
                {
                    // Sort keywords by length descending so "ăn trưa" is checked before "ăn"
                    var sortedKeywords = kvp.Value.OrderByDescending(k => k.Length).ToList();
                    if (sortedKeywords.Any(keyword => lowerText.Contains(keyword)))
                    {
                        matchedCategoryName = kvp.Key;
                        break;
                    }
                }

                if (matchedCategoryName != null)
                {
                    var cat = categories.FirstOrDefault(c => c.Name.ToLower().Contains(matchedCategoryName) || matchedCategoryName.Contains(c.Name.ToLower()));
                    if (cat != null) catId = cat.Id;
                }

                if (catId == null)
                {
                    var firstCat = categories.FirstOrDefault(c => lowerText.Contains(c.Name.ToLower()));
                    if (firstCat != null) catId = firstCat.Id;
                }

                // Super fallback: if matchedCategoryName was "ăn", try to find any category with "ăn"
                if (catId == null && matchedCategoryName == "ăn")
                {
                    var fallbackCat = categories.FirstOrDefault(c => c.Name.ToLower().Contains("ăn") || c.Name.ToLower().Contains("uống") || c.Name.ToLower().Contains("food"));
                    if (fallbackCat != null) catId = fallbackCat.Id;
                }

                var finalCat = categories.FirstOrDefault(c => c.Id == catId);

                // Fix Timezone issue: Force DateTime to be Utc so Flutter parses it without timezone shifts
                if (transactionDate.HasValue)
                {
                    transactionDate = DateTime.SpecifyKind(transactionDate.Value, DateTimeKind.Utc);
                }

                return new VoiceAnalysisResponse
                {
                    Amount = amount,
                    CategoryId = catId,
                    CategoryName = finalCat?.Name,
                    Note = note,
                    TransactionDate = transactionDate
                };
            }

            var requestBody = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[] { new { text = prompt } }
                    }
                },
                generationConfig = new
                {
                    responseMimeType = "application/json"
                }
            };

            var client = _httpClientFactory.CreateClient();
            var response = await client.PostAsync(
                $"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={apiKey}",
                new StringContent(JsonSerializer.Serialize(requestBody), Encoding.UTF8, "application/json"));

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Lỗi khi kết nối với AI Service.");
            }

            var responseContent = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(responseContent);

            try
            {
                var textResult = document.RootElement
                    .GetProperty("candidates")[0]
                    .GetProperty("content")
                    .GetProperty("parts")[0]
                    .GetProperty("text").GetString();

                if (string.IsNullOrEmpty(textResult)) return new VoiceAnalysisResponse();

                var aiResult = JsonSerializer.Deserialize<VoiceAnalysisResponse>(textResult, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                if (aiResult != null && aiResult.CategoryId.HasValue)
                {
                    var cat = categories.FirstOrDefault(c => c.Id == aiResult.CategoryId.Value);
                    if (cat != null) aiResult.CategoryName = cat.Name;
                }

                return aiResult ?? new VoiceAnalysisResponse();
            }
            catch
            {
                return new VoiceAnalysisResponse(); // Trả về object rỗng nếu AI parse lỗi
            }
        }

        private TransactionResponse MapToResponse(Transaction t)
        {
            return new TransactionResponse
            {
                Id = t.Id,
                WalletId = t.WalletId,
                WalletName = t.Wallet?.Name ?? string.Empty,
                CategoryId = t.CategoryId,
                CategoryName = t.Category?.Name ?? string.Empty,
                CategoryIcon = t.Category?.Icon,
                Type = t.Type,
                Amount = t.Amount,
                Note = t.Note,
                TransactionDate = t.TransactionDate,
                CreatedAt = t.CreatedAt
            };
        }
    }
}
