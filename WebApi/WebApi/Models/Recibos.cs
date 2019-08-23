using System;

namespace WebApi.Models
{
    public class Recibos
    {
        private long? id;
        private string proveedor;
        private string moneda;
        private int? idProveedor;
        private int? idMoneda;
        private DateTime? fecha;
        private DateTime? fechaFin;
        private string comentario;
        private string usuario;
        private decimal? monto;
        private decimal? montoFin;
        private DateTime fechaCreacion;
        private DateTime fechaModificacion;

        public long? Id { get => id; set => id = value; }
        public decimal? Monto { get => monto; set => monto = value; }
        public string Comentario { get => comentario; set => comentario = value; }
        public DateTime? Fecha { get => fecha; set => fecha = value; }
        public DateTime FechaModificacion { get => fechaModificacion; set => fechaModificacion = value; }
        public DateTime FechaCreacion { get => fechaCreacion; set => fechaCreacion = value; }
        public decimal? MontoFin { get => montoFin; set => montoFin = value; }
        public DateTime? FechaFin { get => fechaFin; set => fechaFin = value; }
        public string Proveedor { get => proveedor; set => proveedor = value; }
        public int? IdProveedor { get => idProveedor; set => idProveedor = value; }
        public string Moneda { get => moneda; set => moneda = value; }
        public int? IdMoneda { get => idMoneda; set => idMoneda = value; }
        public string Usuario { get => usuario; set => usuario = value; }
    }
}