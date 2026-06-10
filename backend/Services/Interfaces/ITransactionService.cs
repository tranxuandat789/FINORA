using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Requests;
using FinanceAPI.DTOs.Responses;

namespace FinanceAPI.Services.Interfaces
{
    public interface ITransactionService
    {
        Task<IEnumerable<TransactionResponse>> GetTransactionsAsync(Guid userId);
        Task<TransactionResponse> CreateTransactionAsync(CreateTransactionRequest request, Guid userId);
        Task DeleteTransactionAsync(Guid id, Guid userId);
        Task<VoiceAnalysisResponse> AnalyzeVoiceAsync(AnalyzeVoiceRequest request, Guid userId);
    }
}
