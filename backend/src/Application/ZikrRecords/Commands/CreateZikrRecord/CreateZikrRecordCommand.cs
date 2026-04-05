using System;
using MediatR;
using Application.Common.DTOs.ZikrRecords;

namespace Application.ZikrRecords.Commands.CreateZikrRecord;

public class CreateZikrRecordCommand : IRequest<Guid>
{
    public string Phrase { get; set; }
    public int Count { get; set; }
    public DateOnly Date { get; set; }
}
