using System.Threading.Tasks;
using FinanceAPI.DTOs.Auth;
using FinanceAPI.Models;

namespace FinanceAPI.Services
{
    public interface IAuthService
    {
        Task<User> RegisterAsync(RegisterRequest request);
        Task<User> LoginAsync(LoginRequest request);
        Task<User> GoogleLoginAsync(GoogleLoginRequest request);
    }
}
