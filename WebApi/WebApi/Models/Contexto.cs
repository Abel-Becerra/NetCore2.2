using Microsoft.EntityFrameworkCore;

namespace WebApi.Models
{
    public class Contexto : DbContext
    {
        public Contexto(DbContextOptions<Contexto> options) : base(options)
        {
        }
        public DbSet<Recibos> Recibo { get; set; }
        public DbSet<Usuarios> Usuario { get; set; }
        public DbSet<Monedas> Moneda { get; set; }
        public DbSet<Proveedores> Proveedor { get; set; }
    }
}