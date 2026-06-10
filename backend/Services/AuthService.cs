using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.DTOs.Auth;
using FinanceAPI.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;

namespace FinanceAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IPasswordHasher<User> _passwordHasher;
        private readonly IConfiguration _configuration;

        public AuthService(AppDbContext context, IPasswordHasher<User> passwordHasher, IConfiguration configuration)
        {
            _context = context;
            _passwordHasher = passwordHasher;
            _configuration = configuration;
        }

        public async Task<User> RegisterAsync(RegisterRequest request)
        {
            // Check if email already exists
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (existingUser != null)
            {
                throw new Exception("Email đã được sử dụng."); // Will be caught by global error handler
            }

            var newUser = new User
            {
                Id = Guid.NewGuid(),
                FullName = request.FullName.Trim(),
                Email = request.Email.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            newUser.PasswordHash = _passwordHasher.HashPassword(newUser, request.Password);

            _context.Users.Add(newUser);

            // Create default wallet
            var defaultWallet = new Wallet
            {
                Id = Guid.NewGuid(),
                UserId = newUser.Id,
                Name = "Tiền mặt",
                Type = FinanceAPI.Models.Enums.WalletType.Cash,
                Balance = 0,
                Icon = "wallet_icon",
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            };
            _context.Wallets.Add(defaultWallet);

            // Create default categories
            CreateDefaultCategories(newUser.Id);

            await _context.SaveChangesAsync();

            return newUser;
        }

        public async Task<User> LoginAsync(LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email && !u.IsDeleted);
            if (user == null)
            {
                throw new Exception("Email hoặc mật khẩu không chính xác.");
            }

            var verificationResult = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
            if (verificationResult == PasswordVerificationResult.Failed)
            {
                throw new Exception("Email hoặc mật khẩu không chính xác.");
            }

            // Check and create default wallet if missing
            var hasWallet = await _context.Wallets.AnyAsync(w => w.UserId == user.Id && !w.IsDeleted);
            if (!hasWallet)
            {
                var defaultWallet = new Wallet
                {
                    Id = Guid.NewGuid(),
                    UserId = user.Id,
                    Name = "Tiền mặt",
                    Type = FinanceAPI.Models.Enums.WalletType.Cash,
                    Balance = 0,
                    Icon = "wallet_icon",
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };
                _context.Wallets.Add(defaultWallet);
                await _context.SaveChangesAsync();
            }

            return user;
        }

        public async Task<User> GoogleLoginAsync(GoogleLoginRequest request)
        {
            GoogleJsonWebSignature.Payload payload;
            try
            {
                var settings = new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { _configuration["Authentication:Google:ClientId"] }
                };
                payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, settings);
            }
            catch (InvalidJwtException)
            {
                throw new Exception("Google Token không hợp lệ.");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == payload.Email && !u.IsDeleted);
            
            if (user == null)
            {
                // User does not exist, create automatically
                user = new User
                {
                    Id = Guid.NewGuid(),
                    FullName = payload.Name,
                    Email = payload.Email,
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };

                // Generate a strong random password for Google-authenticated users
                var randomPassword = Guid.NewGuid().ToString() + "A1!";
                user.PasswordHash = _passwordHasher.HashPassword(user, randomPassword);

                _context.Users.Add(user);

                // Create default wallet
                var defaultWallet = new Wallet
                {
                    Id = Guid.NewGuid(),
                    UserId = user.Id,
                    Name = "Tiền mặt",
                    Type = FinanceAPI.Models.Enums.WalletType.Cash,
                    Balance = 0,
                    Icon = "wallet_icon",
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };
                _context.Wallets.Add(defaultWallet);

                // Create default categories
                CreateDefaultCategories(user.Id);

                await _context.SaveChangesAsync();
            }

            return user;
        }

        private void CreateDefaultCategories(Guid userId)
        {
            var foodId = Guid.NewGuid();
            var transportId = Guid.NewGuid();
            var shoppingId = Guid.NewGuid();
            var homeId = Guid.NewGuid();
            var entertainId = Guid.NewGuid();
            var healthId = Guid.NewGuid();
            var socialId = Guid.NewGuid();
            var spiritId = Guid.NewGuid();
            var educationId = Guid.NewGuid();
            var othersId = Guid.NewGuid();

            var categories = new List<Category>
            {
                // Chi tiêu
                new Category { Id = foodId, UserId = userId, Name = "Ăn uống", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "restaurant", IsDeleted = false },
                new Category { Id = transportId, UserId = userId, Name = "Di chuyển", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "two_wheeler", IsDeleted = false },
                new Category { Id = shoppingId, UserId = userId, Name = "Mua sắm", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "shopping_bag", IsDeleted = false },
                new Category { Id = homeId, UserId = userId, Name = "Nhà cửa & Hóa đơn", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "home", IsDeleted = false },
                new Category { Id = entertainId, UserId = userId, Name = "Giải trí", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "sports_esports", IsDeleted = false },
                new Category { Id = healthId, UserId = userId, Name = "Y tế & Sức khỏe", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "local_hospital", IsDeleted = false },
                new Category { Id = socialId, UserId = userId, Name = "Quan hệ xã hội", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "diversity_1", IsDeleted = false },
                new Category { Id = spiritId, UserId = userId, Name = "Tâm linh & Đồ lễ", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "volunteer_activism", IsDeleted = false },
                new Category { Id = educationId, UserId = userId, Name = "Giáo dục & Con cái", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "school", IsDeleted = false },
                new Category { Id = othersId, UserId = userId, Name = "Khác", Type = FinanceAPI.Models.Enums.TransactionType.Expense, Icon = "more_horiz", IsDeleted = false },
                
                // Thu nhập
                new Category { Id = Guid.NewGuid(), UserId = userId, Name = "Tiền lương", Type = FinanceAPI.Models.Enums.TransactionType.Income, Icon = "payments", IsDeleted = false },
                new Category { Id = Guid.NewGuid(), UserId = userId, Name = "Tiền thưởng", Type = FinanceAPI.Models.Enums.TransactionType.Income, Icon = "card_giftcard", IsDeleted = false },
                new Category { Id = Guid.NewGuid(), UserId = userId, Name = "Tiền lãi / Đầu tư", Type = FinanceAPI.Models.Enums.TransactionType.Income, Icon = "trending_up", IsDeleted = false },
                new Category { Id = Guid.NewGuid(), UserId = userId, Name = "Bán đồ / Thanh lý", Type = FinanceAPI.Models.Enums.TransactionType.Income, Icon = "storefront", IsDeleted = false },
                new Category { Id = Guid.NewGuid(), UserId = userId, Name = "Được tặng / Cho", Type = FinanceAPI.Models.Enums.TransactionType.Income, Icon = "redeem", IsDeleted = false }
            };

            _context.Categories.AddRange(categories);

            var startDate = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
            var budgets = new List<Budget>
            {
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = foodId, BaseAmount = 2500000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = transportId, BaseAmount = 400000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = shoppingId, BaseAmount = 500000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = homeId, BaseAmount = 1500000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = entertainId, BaseAmount = 500000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = healthId, BaseAmount = 300000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = socialId, BaseAmount = 500000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = spiritId, BaseAmount = 100000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = educationId, BaseAmount = 500000m, StartDate = startDate, IsDeleted = false },
                new Budget { Id = Guid.NewGuid(), UserId = userId, CategoryId = othersId, BaseAmount = 200000m, StartDate = startDate, IsDeleted = false }
            };

            _context.Budgets.AddRange(budgets);
        }
    }
}
