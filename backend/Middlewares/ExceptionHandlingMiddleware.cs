using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace FinanceAPI.Middlewares
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unhandled exception occurred.");
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

            // Optional: Customize based on exception type if needed
            var message = "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.";
            
            // Allow business logic exceptions to pass their message
            if (exception is ArgumentException || exception.Message.Contains("không hợp lệ") || exception.Message.Contains("tồn tại") || exception.Message.Contains("không chính xác"))
            {
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                message = exception.Message;
            }

            var response = ApiResponse<object>.Fail(message);
            var result = JsonSerializer.Serialize(response);

            return context.Response.WriteAsync(result);
        }
    }
}
