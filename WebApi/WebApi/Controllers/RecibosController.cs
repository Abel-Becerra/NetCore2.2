using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using WebApi.Models;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecibosController : ControllerBase
    {
        private readonly Contexto _context;
        public RecibosController(Contexto context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<ActionResult<IEnumerable<Recibos>>> Get(Recibos recibo)
        {
            var p1 = new SqlParameter()
            {
                ParameterName = "@Id",
                SqlDbType = System.Data.SqlDbType.BigInt,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.Id
            };
            var p2 = new SqlParameter()
            {
                ParameterName = "@IdProveedor",
                SqlDbType = System.Data.SqlDbType.Int,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.IdProveedor
            };
            var p3 = new SqlParameter()
            {
                ParameterName = "@IdMoneda",
                SqlDbType = System.Data.SqlDbType.Int,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.IdMoneda
            };
            var p4 = new SqlParameter()
            {
                ParameterName = "@MontoInicio",
                SqlDbType = System.Data.SqlDbType.Decimal,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.Monto,
                Scale = 2,
                Precision = 19
            };
            var p5 = new SqlParameter()
            {
                ParameterName = "@MontoFin",
                SqlDbType = System.Data.SqlDbType.Decimal,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.MontoFin,
                Scale = 2,
                Precision = 19
            };
            var p6 = new SqlParameter()
            {
                ParameterName = "@FechaInicio",
                SqlDbType = System.Data.SqlDbType.Date,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.Fecha
            };
            var p7 = new SqlParameter()
            {
                ParameterName = "@FechaFin",
                SqlDbType = System.Data.SqlDbType.Date,
                Direction = System.Data.ParameterDirection.Input,
                Value = recibo.FechaFin
            };

            if (recibo.Id is null)
            {
                p1.Value = DBNull.Value;
            }
            if (recibo.IdProveedor is null)
            {
                p2.Value = DBNull.Value;
            }
            if (recibo.IdMoneda is null)
            {
                p3.Value = DBNull.Value;
            }
            if (recibo.Monto is null)
            {
                p4.Value = DBNull.Value;
            }
            if (recibo.MontoFin is null)
            {
                p5.Value = DBNull.Value;
            }
            if (recibo.Fecha is null)
            {
                p6.Value = DBNull.Value;
            }
            if (recibo.FechaFin is null)
            {
                p7.Value = DBNull.Value;
            }

            var items = await _context.Recibo.FromSql($"EXEC RecibosObtener @Id, @IdProveedor, @IdMoneda, @MontoInicio, @MontoFin, @FechaInicio, @FechaFin", p1, p2, p3, p4, p5, p6, p7).ToListAsync();

            return items;
        }

        [HttpPut]
        public async Task<ActionResult<long>> Post(Recibos recibo)
        {
            StringBuilder sb = new StringBuilder();
            if (recibo.Fecha is null) {
                sb.AppendLine("Se requiere la FECHA del recibo");
            }
            if (recibo.Monto is null)
            {
                sb.AppendLine("Se requiere el MONTO del recibo");
            }
            if (recibo.IdProveedor is null || recibo.Proveedor is null)
            {
                sb.AppendLine("Se requiere el PROVEEDOR al que se le realiza el recibo");
            }
            if (recibo.IdMoneda is null || recibo.Moneda is null)
            {
                sb.AppendLine("Se requiere la MONEDA del MONTO del recibo");
            }
            if (sb.Length > 0) {
                throw new Exception(sb.ToString());
            }

            var param = new SqlParameter()
            {
                ParameterName = "@Id",
                SqlDbType = System.Data.SqlDbType.BigInt,
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = recibo.Id ?? 0
            };

            await _context.Database.ExecuteSqlCommandAsync($"RecibosGuardar @Id output, {recibo.IdProveedor}, '{recibo.Proveedor}', {recibo.IdMoneda}, '{recibo.Moneda}', {recibo.Monto}, '{(recibo.Fecha ?? DateTime.Now).ToString("yyyy-MM-dd")}', '{recibo.Comentario}', '{recibo.Usuario}'", param);

            return (long)param.Value;
        }
    }
}