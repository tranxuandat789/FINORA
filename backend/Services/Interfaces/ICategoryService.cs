using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.Models;
using FinanceAPI.Models.DTOs;

namespace FinanceAPI.Services.Interfaces
{
    public interface ICategoryService
    {
        Task<IEnumerable<Category>> GetCategoriesAsync(Guid userId);
        Task<Category> CreateCategoryAsync(Guid userId, CategoryCreateDto request);
        Task DeleteCategoryAsync(Guid id, Guid userId);
    }
}
