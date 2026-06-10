using System.Collections.Generic;

namespace FinanceAPI.DTOs.Responses
{
    public class GoalDetailResponse : GoalResponse
    {
        public List<ContributionResponse> Contributions { get; set; } = new();
    }
}
