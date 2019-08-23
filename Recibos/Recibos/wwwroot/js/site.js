var site = {}

site.uri = "http://localhost:50391/api/"

site.spinner = '<div class="spinner-grow spinner-grow-sm" role="status"></div>'

site.alert = '<div class="alert alert-warning alert-dismissible fade show" role="alert">{msg}<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>'

site.error = '<div class="alert alert-danger alert-dismissible fade show" role="alert">No fue posible realizar el proceso, hubo un error, favor de contactar al administrador del sistema<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>'

site.classAlert = ".alert-dismissible"

site.monedas = {}

site.proveedores = {}

site.optionsDateFormat = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }

site.optBttnTbl = '<button type="button" class="btn btn-outline-primary btn-sm" title="Editar" onclick="site.edit({params})" data-toggle="modal" data-target="#recibo"><i class="fas fa-money-check-alt"></i></button>'

site.new = () => {
    $("#tituloModal").text("Nuevo Recibo")
    site.setControls("", "", "", "", "", 0)
    site.generateSearchBox()
}

site.generateSearchBox = () => {
    $('#proveedor').autocomplete({
        nameProperty: 'nombre',
        valueField: '#idproveedor',
        valueProperty: "id",
        dataSource: site.proveedores
    });
    $('#moneda').autocomplete({
        nameProperty: 'nombre',
        valueField: '#idmoneda',
        valueProperty: "id",
        dataSource: site.monedas
    });
    $("#guardarRecibo").off().on("click", site.save)
}

site.edit = (id, prov, mon, mnt, fch, com) => {
    site.setControls(id, prov, com, fch, mon, mnt)
    $("#tituloModal").text("Editar Recibo #" + id)
    site.generateSearchBox()
}

site.setControls = (i, p, c, f, m, _m) => {
    $("#comentario").val(atob(c))
    $("#fecha").val(f == "" ? "" : new Date(f).toISOString().split('T')[0])
    $("#monto").val(_m)
    $("#id").val(i)
    $("#idmoneda").val(m)
    $("#moneda").val(m)
    $("#idproveedor").val(p)
    $("#proveedor").val(p)
    
    if (m != "") {
        let y = $.grep(site.monedas, function (e, i) { return e.id == m })
        y =y.length > 0 ? y[0].nombre : ""
        $("#moneda").val(y)
    }
    if (p != "") {
        let w = $.grep(site.proveedores, function (e, i) { return e.id == p })
        w = w.length > 0 ? w[0].nombre : ""
        $("#proveedor").val(w)
    }
}

site.getValueControls = () => {
    var item = {}
    item.IdProveedor = $("#idproveedor").val() == "" ? 0 : $("#idproveedor").val()
    item.Proveedor = $("#proveedor").val() == "" ? null : $("#proveedor").val()
    item.Comentario = btoa($("#comentario").val())
    item.Fecha = $("#fecha").val()
    item.IdMoneda = $("#idmoneda").val() == "" ? 0 : $("#idmoneda").val()
    item.Moneda = $("#moneda").val() == "" ? null : $("#moneda").val()
    item.Monto = $("#monto").val()
    item.Id = $("#id").val() == "" ? null : $("#id").val()
    item.Usuario = sessionStorage.getItem("Usuario")
    return item
}

site.validate = () => {
    let flag = true
    if ($("#proveedor").val() == "") {
        flag = false
        $("#proveedor").addClass("alert-danger").change(function () {
            $(this).removeClass("alert-danger")
        }).blur(function () {
            $(this).removeClass("alert-danger")
        })
        var t = $(site.alert.replace("{msg}", "Se requiere que indique un Proveedor.")).appendTo("#recibo")
        t.fadeTo(2000, 500).slideUp(500, function () {
            $(site.classAlert).alert('close');
        });
    }
    if ($("#fecha").val() == "") {
        flag = false
        $("#fecha").addClass("alert-danger").blur(function () {
            $(this).removeClass("alert-danger")
        })
        var t = $(site.alert.replace("{msg}", "Se requiere que indique la Fecha del recibo.")).appendTo("#recibo")
        t.fadeTo(2000, 500).slideUp(500, function () {
            $(site.classAlert).alert('close');
        });
    }
    if ($("#moneda").val() == "") {
        flag = false
        $("#moneda").addClass("alert-danger").change(function () {
            $(this).removeClass("alert-danger")
        }).blur(function () {
            $(this).removeClass("alert-danger")
        })
        var t = $(site.alert.replace("{msg}", "Se requiere que indique la Moneda del monto del recibo.")).appendTo("#recibo")
        t.fadeTo(2000, 500).slideUp(500, function () {
            $(site.classAlert).alert('close');
        });
    }
    if ($("#monto").val() == "") {
        flag = false
        $("#monto").addClass("alert-danger").blur(function () {
            $(this).removeClass("alert-danger")
        })
        var t = $(site.alert.replace("{msg}", "Se requiere que indique el Monto del recibo.")).appendTo("#recibo")
        t.fadeTo(2000, 500).slideUp(500, function () {
            $(site.classAlert).alert('close');
        });
    }
    return flag
}

site.initLogIn = () => {
    $(".container").parent().addClass("backBodyLogIn")
    $("#login").on("click", function () {
        const item = {
            Usuario: $("#Usuario").val(),
            Contraseña: btoa($("#Contrasegna").val())
        };
        let flag = true;

        if (item.Usuario == undefined || item.Usuario == null || item.Usuario == "") {
            $("#Usuario").addClass("alert-danger").blur(function () {
                $(this).removeClass("alert-danger")
            })
            var t = $(site.alert.replace("{msg}", "Se requiere que indique su Usuario.")).appendTo(".container")
            t.fadeTo(2000, 500).slideUp(500, function () {
                $(site.classAlert).alert('close');
            });
            flag = false
        }

        if (item.Contraseña == undefined || item.Contraseña == null || item.Contraseña == "") {
            $("#Contrasegna").addClass("alert-danger").blur(function () {
                $(this).removeClass("alert-danger")
            })
            var t = $(site.alert.replace("{msg}","Se requiere que indique su Contraseña.")).appendTo(".container")
            t.fadeTo(2000, 500).slideUp(500, function () {
                $(site.classAlert).alert('close');
            });
            flag = false
        }

        if (flag == false) {
            return false;
        }

        var y = $(site.spinner).appendTo("#login")
        $(this).prop("disabled", true)

        $.ajax({
            url: site.uri + "catalogos/acceso",
            type: "POST",
            accepts: "application/json",
            contentType: "application/json",
            data: JSON.stringify(item),
            success: function (result) {
                y.remove()
                $("#login").prop("disabled", false)
                if (result.acceso == false) {
                    var t = $(site.alert.replace("{msg}", "Usted no tiene acceso al sistema.")).appendTo(".container")
                    t.fadeTo(2000, 500).slideUp(500, function () {
                        $(site.classAlert).alert('close');
                    });
                } else {
                    sessionStorage.setItem("Nombre", result.nombre);
                    sessionStorage.setItem("Usuario", result.usuario);
                    window.location.href ="/home/recibos"
                }
            }
        }).fail(function () {
            y.remove()
            $("#login").prop("disabled", false)
            var t = $(site.error).appendTo("#recibo")
            t.fadeTo(2000, 500).slideUp(500, function () {
                $(site.classAlert).alert('close');
            });
        });

        return false;
    });
}

site.loadMonedas = () => {
    $.ajax({
        url: site.uri + "catalogos/monedas",
        type: "GET",
        accepts: "application/json",
        contentType: "application/json",
        data: JSON.stringify({}),
        success: function (result) {
            site.monedas = result
            $("#_moneda").empty()
            $("#_moneda").append("<option value=''>-- Selecciona una Moneda --</option>")
            $.each(result, function (i, e) {
                $("#_moneda").append("<option value='" + e.id + "'>" + e.nombre + "</option>")
            })
        }
    });
}

site.loadProveedores = () => {
    $.ajax({
        url: site.uri + "catalogos/proveedores",
        type: "GET",
        accepts: "application/json",
        contentType: "application/json",
        data: JSON.stringify({}),
        success: function (result) {
            site.proveedores = result
            $("#_proveedor").empty()
            $("#_proveedor").append("<option value=''>-- Selecciona un Proveedor --</option>")
            $.each(result, function (i, e) {
                $("#_proveedor").append("<option value='" + e.id + "'>" + e.nombre + "</option>")
            })
        }
    });
}

site.loadRecibos = () => {
    $("#recibos").empty()
    $("#recibos").append("<tr><td colspan='7'>" + site.spinner + "</td></tr>")
    let item = {}
    item.Id = $("#_id").val() == "" ? null : $("#_id").val()
    item.IdProveedor = $("#_proveedor").val() == "" ? null : $("#_proveedor").val()
    item.IdMoneda = $("#_moneda").val() == "" ? null : $("#_moneda").val()
    item.Monto = $("#_montoinicio").val() == "" ? null : $("#_montoinicio").val()
    item.MontoFin = $("#_montofin").val() == "" ? null : $("#_montofin").val()
    item.Fecha = $("#_fechainicio").val() == "" ? null : $("#_fechainicio").val()
    item.FechaFin = $("#_fechafin").val() == "" ? null : $("#_fechafin").val()
    $.ajax({
        url: site.uri + "recibos",
        type: "POST",
        accepts: "application/json",
        contentType: "application/json",
        data: JSON.stringify(item),
        success: function (result) {
            $("#recibos").empty()
            $.each(result, function (i, o) {
                let x = site.optBttnTbl
                x = x.replace("{params}", o.id + "," + o.idProveedor + "," + o.idMoneda + "," + o.monto + ",'" + o.fecha + "','" + o.comentario + "'")
                $('<tr><td>' + x + '</td><td>' + o.id + '</td><td>' + o.proveedor + '</td><td>' + '$ ' + (o.monto).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</td><td>' + o.moneda + '</td><td>' + new Date(o.fecha).toLocaleDateString('es-MX', site.optionsDateFormat) + '</td><td>' + atob(o.comentario) + '</td></tr>').appendTo("#recibos")
            })

            if (result.length == 0) {
                $("#recibos").append("<tr><td colspan='7'>No existen registros a mostrar</td></tr>")
            }
        }
    });
}

site.initRecibos = () => {
    site.loadMonedas()
    site.loadProveedores()
    setTimeout(function () { site.loadRecibos(); }, 1000)
    $("#hdrUsuario").text("Bienvenido " + sessionStorage.getItem("Nombre"))
}

site.save = function () {
    if (site.validate()) {
        var k = $(site.spinner).appendTo("#guardarRecibo")
        $(this).prop("disabled", true)
        $.ajax({
            url: site.uri + "recibos",
            type: "PUT",
            accepts: "application/json",
            contentType: "application/json",
            data: JSON.stringify(site.getValueControls()),
            success: function (result) {
                k.remove()
                $("#guardarRecibo").prop("disabled", false)
                $("#id").val(result)
                var t = $(site.alert.replace("alert-warning", "alert-success").replace("{msg}", "Folio de Recibo generado # " + result)).appendTo("#recibo")
                t.fadeTo(2000, 500).slideUp(500, function () {
                    $(site.classAlert).alert('close');
                    $("#recibo").modal("hide")
                });
                site.loadRecibos()
                site.loadMonedas()
                site.loadProveedores()
            }
        }).fail(function () {
            $("#guardarRecibo").prop("disabled", false)
            k.remove()
            var t = $(site.error).appendTo("#recibo")
            t.fadeTo(2000, 500).slideUp(500, function () {
                $(site.classAlert).alert('close');
            });
        });
    }
}