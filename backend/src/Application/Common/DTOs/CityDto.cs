using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Application.Common.DTOs
{
    public class CityDto
    {
        public int SehirID { get; set; }
        public string SehirAdi { get; set; } = default!;
    }

}