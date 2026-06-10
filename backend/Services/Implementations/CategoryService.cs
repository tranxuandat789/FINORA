using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using FinanceAPI.Data;
using FinanceAPI.Models;
using FinanceAPI.Models.DTOs;
using FinanceAPI.Services.Interfaces;

namespace FinanceAPI.Services.Implementations
{
    public class CategoryService : ICategoryService
    {
        private readonly AppDbContext _context;

        public CategoryService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Category>> GetCategoriesAsync(Guid userId)
        {
            return await _context.Categories
                .Where(c => !c.IsDeleted && (c.UserId == null || c.UserId == userId))
                .OrderBy(c => c.Name)
                .ToListAsync();
        }

        public async Task<Category> CreateCategoryAsync(Guid userId, CategoryCreateDto request)
        {
            var category = new Category
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Name = request.Name,
                Type = request.Type,
                Icon = request.Icon,
                IsDeleted = false
            };

            _context.Categories.Add(category);
            await _context.SaveChangesAsync();

            return category;
        }

        public async Task DeleteCategoryAsync(Guid id, Guid userId)
        {
            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId && !c.IsDeleted);

            if (category == null)
            {
                throw new Exception("Danh mục không tồn tại hoặc bạn không có quyền xóa (không thể xóa danh mục mặc định).");
            }

            // Mềm xóa (Soft delete)
            category.IsDeleted = true;
            await _context.SaveChangesAsync();
        }
    }
}
