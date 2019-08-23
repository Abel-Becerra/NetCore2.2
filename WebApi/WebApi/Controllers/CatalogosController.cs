using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using WebApi.Models;

namespace WebApi.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CatalogosController : ControllerBase
    {
        private readonly Contexto _context;

        public CatalogosController(Contexto context)
        {
            _context = context;
        }

        [HttpPost]
        [ActionName("acceso")]
        public async Task<ActionResult<Usuarios>> Usuario(Usuarios usuarios)
        {
            byte[] data = System.Convert.FromBase64String(usuarios.Contraseña);
            usuarios.Contraseña = System.Text.ASCIIEncoding.ASCII.GetString(data);

            var param = new SqlParameter()
            {
                ParameterName = "@Acceso",
                SqlDbType = System.Data.SqlDbType.Bit,
                Direction = System.Data.ParameterDirection.Output
            };
            var param1 = new SqlParameter()
            {
                ParameterName = "@Nombre",
                SqlDbType = System.Data.SqlDbType.VarChar,
                Direction = System.Data.ParameterDirection.Output,
                Size = 1000
            };

            await _context.Database.ExecuteSqlCommandAsync($"UsuariosObtener '{usuarios.Usuario}', '{usuarios.Contraseña}', @Acceso output, @Nombre output", param, param1);

            usuarios.Nombre = (string)(param1.Value == System.DBNull.Value || param1.Value is null ? string.Empty : param1.Value);
            usuarios.Acceso = (bool)param.Value;
            usuarios.Contraseña = string.Empty;

            return usuarios;
        }

        [HttpGet]
        [ActionName("monedas")]
        public async Task<ActionResult<IEnumerable<Monedas>>> Monedas()
        {
            var items = await _context.Moneda.FromSql<Monedas>("MonedasObtener").ToListAsync();
            return items;
        }

        [HttpGet]
        [ActionName("proveedores")]
        public async Task<ActionResult<IEnumerable<Proveedores>>> Proveedores()
        {
            var items = await _context.Proveedor.FromSql<Proveedores>("ProveedoresObtener").ToListAsync();
            return items;
        }
    }
}