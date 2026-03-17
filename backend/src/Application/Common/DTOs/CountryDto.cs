using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Application.Common.DTOs
{
    public class CountryDto
    {
        public int UlkeID { get; set; }
        public string UlkeAdi { get; set; } = default!;
    }

}