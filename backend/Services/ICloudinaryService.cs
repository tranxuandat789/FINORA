using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace FinanceAPI.Services
{
    public interface ICloudinaryService
    {
        /// <summary>Upload ảnh lên Cloudinary, trả về secure URL</summary>
        Task<string> UploadImageAsync(IFormFile file, string folder = "finora/avatars");
    }
}
