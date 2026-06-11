using System;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace FinanceAPI.Services.Implementations
{
    public class CloudinaryService : ICloudinaryService
    {
        private readonly string _cloudName;
        private readonly string _apiKey;
        private readonly string _apiSecret;
        private readonly HttpClient _httpClient;

        public CloudinaryService(IConfiguration configuration, IHttpClientFactory httpClientFactory)
        {
            _cloudName = configuration["Cloudinary:CloudName"]
                         ?? throw new InvalidOperationException("Cloudinary:CloudName chưa được cấu hình");
            _apiKey = configuration["Cloudinary:ApiKey"]
                      ?? throw new InvalidOperationException("Cloudinary:ApiKey chưa được cấu hình");
            _apiSecret = configuration["Cloudinary:ApiSecret"]
                         ?? throw new InvalidOperationException("Cloudinary:ApiSecret chưa được cấu hình");
            _httpClient = httpClientFactory.CreateClient();
        }

        public async Task<string> UploadImageAsync(IFormFile file, string folder = "finora/avatars")
        {
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
            var publicId = $"{folder}/{Guid.NewGuid()}";

            // Signature: SHA1 of "folder={folder}&public_id={publicId}&timestamp={timestamp}{apiSecret}"
            var signaturePayload = $"folder={folder}&public_id={publicId}&timestamp={timestamp}{_apiSecret}";
            var signature = ComputeSha1(signaturePayload);

            using var formData = new MultipartFormDataContent();

            // Đọc file stream
            await using var stream = file.OpenReadStream();
            var fileContent = new StreamContent(stream);
            fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType ?? "image/jpeg");
            formData.Add(fileContent, "file", file.FileName);

            formData.Add(new StringContent(_apiKey), "api_key");
            formData.Add(new StringContent(timestamp), "timestamp");
            formData.Add(new StringContent(signature), "signature");
            formData.Add(new StringContent(folder), "folder");
            formData.Add(new StringContent(publicId), "public_id");

            var response = await _httpClient.PostAsync(
                $"https://api.cloudinary.com/v1_1/{_cloudName}/image/upload",
                formData
            );

            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
                throw new Exception($"Cloudinary upload thất bại: {responseBody}");

            var result = JsonSerializer.Deserialize<CloudinaryUploadResult>(responseBody,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return result?.SecureUrl
                   ?? throw new Exception("Không nhận được URL từ Cloudinary");
        }

        private static string ComputeSha1(string input)
        {
            var bytes = SHA1.HashData(Encoding.UTF8.GetBytes(input));
            var sb = new StringBuilder();
            foreach (var b in bytes)
                sb.Append(b.ToString("x2"));
            return sb.ToString();
        }

        private class CloudinaryUploadResult
        {
            [JsonPropertyName("secure_url")]
            public string? SecureUrl { get; set; }

            [JsonPropertyName("public_id")]
            public string? PublicId { get; set; }
        }
    }
}
