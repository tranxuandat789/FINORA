using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;

namespace FinanceAPI.Services.Implementations
{
    public class CloudinaryService : ICloudinaryService
    {
        private readonly Cloudinary _cloudinary;

        public CloudinaryService(IConfiguration configuration)
        {
            var cloudName = configuration["Cloudinary:CloudName"]
                         ?? throw new InvalidOperationException("Cloudinary:CloudName chưa được cấu hình");
            var apiKey = configuration["Cloudinary:ApiKey"]
                      ?? throw new InvalidOperationException("Cloudinary:ApiKey chưa được cấu hình");
            var apiSecret = configuration["Cloudinary:ApiSecret"]
                         ?? throw new InvalidOperationException("Cloudinary:ApiSecret chưa được cấu hình");

            var account = new Account(cloudName, apiKey, apiSecret);
            _cloudinary = new Cloudinary(account);
        }

        public async Task<string> UploadImageAsync(IFormFile file, string folder = "finora/avatars")
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File không hợp lệ.");

            await using var stream = file.OpenReadStream();
            
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Folder = folder,
                PublicId = Guid.NewGuid().ToString()
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);

            if (uploadResult.Error != null)
                throw new Exception($"Cloudinary upload thất bại: {uploadResult.Error.Message}");

            return uploadResult.SecureUrl?.ToString() 
                   ?? throw new Exception("Không nhận được URL từ Cloudinary");
        }
    }
}
