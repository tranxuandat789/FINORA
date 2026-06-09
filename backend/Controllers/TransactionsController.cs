using System;
using System.Security.Claims;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Common;
using FinanceAPI.DTOs.Requests;
using FinanceAPI.DTOs.Responses;
using FinanceAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinanceAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TransactionsController : ControllerBase
    {
        private readonly ITransactionService _transactionService;

        public TransactionsController(ITransactionService transactionService)
        {
            _transactionService = transactionService;
        }

        private Guid GetUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                throw new UnauthorizedAccessException("Người dùng chưa đăng nhập hợp lệ.");
            }
            return userId;
        }

        [HttpGet]
        public async Task<IActionResult> GetTransactions()
        {
            try
            {
                var userId = GetUserId();
                var result = await _transactionService.GetTransactionsAsync(userId);
                return Ok(ApiResponse<object>.Ok(result, "Lấy danh sách giao dịch thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateTransaction([FromBody] CreateTransactionRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ."));
            }

            try
            {
                var userId = GetUserId();
                var result = await _transactionService.CreateTransactionAsync(request, userId);
                return Ok(ApiResponse<TransactionResponse>.Ok(result, "Thêm giao dịch thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTransaction(Guid id)
        {
            try
            {
                var userId = GetUserId();
                await _transactionService.DeleteTransactionAsync(id, userId);
                return Ok(ApiResponse<object>.Ok(new {}, "Xóa giao dịch thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        [HttpPost("analyze-voice")]
        public async Task<IActionResult> AnalyzeVoice([FromBody] AnalyzeVoiceRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ."));
            }

            try
            {
                var userId = GetUserId();
                var result = await _transactionService.AnalyzeVoiceAsync(request, userId);
                return Ok(ApiResponse<VoiceAnalysisResponse>.Ok(result, "Phân tích giọng nói thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }
    }
}
