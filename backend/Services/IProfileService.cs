using System;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Profile;
using Microsoft.AspNetCore.Http;

namespace FinanceAPI.Services
{
    public interface IProfileService
    {
        Task<ProfileResponse> GetProfileAsync(Guid userId);
        Task<ProfileResponse> UpdateProfileAsync(Guid userId, UpdateProfileRequest request);
        Task ChangePasswordAsync(Guid userId, ChangePasswordRequest request);
        Task<string> UploadAvatarAsync(Guid userId, IFormFile file);
    }
}
