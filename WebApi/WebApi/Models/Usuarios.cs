namespace WebApi.Models
{
    public class Usuarios : ModeloBase
    {
        private string contraseña;
        private string usuario;
        private bool acceso;

        public string Usuario { get => usuario; set => usuario = value; }
        public string Contraseña { get => contraseña; set => contraseña = value; }
        public bool Acceso { get => acceso; set => acceso = value; }
    }
}