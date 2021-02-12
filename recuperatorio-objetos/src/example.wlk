object empresa{
	const descargas = []
	
	method precioDescarga(producto,usuario){
		const derechosDeAutor = producto.derechosDeAutor()
		const totalSinRecargo = usuario.montoParaDeEmpresa(derechosDeAutor) + self.gananciaEmpresa(derechosDeAutor)
		return usuario.recargo(totalSinRecargo) + totalSinRecargo
	}
	
	method gananciaEmpresa(monto) = monto * 0.25
	
	method descargarProducto(producto,usuario){
		const precio = self.precioDescarga(producto,usuario)
		if(usuario.puedePagar(precio)){
			const descarga = new Descarga(producto=producto,usuario=usuario)
			usuario.descontar(precio)
			producto.acumularDescarga()
			self.registrarDescarga(descarga)
		} else{
			throw new DomainException(message="El usuario no puede realizar la descarga")
		}
	}
	
	method gastoMensual(cliente){
		const descargasDelMes = self.descargasDelMes(cliente)
		return descargasDelMes.sum({unaDescarga => self.precioDescarga(unaDescarga.producto(),unaDescarga.usuario())})
	}
	
	method descargasDelMes(cliente) {
		return descargas.descargasDeUsuario(cliente).filter({unaDescarga => unaDescarga.esDeMesActual()})
	} 
	
	method descargasDeUsuario(cliente) = descargas.filter({unaDescarga => unaDescarga.usuario() == cliente})
	
	method registrarDescarga(descarga){
		descargas.add(descarga)
	}
	
	method esColgado(cliente) = self.tieneDescargasRepetidas(cliente)
	
	method tieneDescargasRepetidas(cliente){
		return self.descargasDeUsuario(cliente).map({unaDescarga => unaDescarga.producto()}).size() > self.descargasDeUsuario(cliente).map({unaDescarga => unaDescarga.producto()}).asSet().size()
	}
	
	method masDescargado(fecha) = self.descargasDelDia(fecha).max({unaDescarga => unaDescarga.producto().descargas()})

	method descargasDelDia(fecha) = descargas.filter({unaDescarga => unaDescarga.esDeFecha(fecha)})
}

class Producto{
	const property nombre
	var property descargas = 0
	method acumularDescarga(){
		descargas++
	}
}

class Ringtone inherits Producto{
	const property duracion
	var property precioMinuto
	method derechosDeAutor() = duracion * precioMinuto
}

class Chiste inherits Producto{
	const property montoFijo
	const property chiste
	method derechosDeAutor() = chiste.size() * montoFijo
}

class Juego inherits Producto{
	var property derechosDeAutor
}

class Usuario{
	
	var property dineroEnCuenta
	var property empresa
	var property tipoPlan
	var property montoAcumulado = 0
	method recargo(monto) = tipoPlan.recargo(monto) 
	
	method puedePagar(monto) = dineroEnCuenta > monto
	
	method descontar(monto) {
		tipoPlan.descontar(monto,self)
	}
	
	method quitarDinero(monto) {
		dineroEnCuenta -= monto
	}
	
	method montoParaDeEmpresa(derechosDeAutor) = empresa.montopara(derechosDeAutor)
	
	method agregarAcumulado(monto){
		montoAcumulado+=monto
	}
}

class EmpresaTelecomunicaciones{
	
	
	method montoPara(derechosDeAutor) = derechosDeAutor * 0.05
}

class EmpresaTelecomunicacionesExtranjera inherits EmpresaTelecomunicaciones{
	var property impuestoPrestacion
	
	override method montoPara(derechosDeAutor) = super(derechosDeAutor) + impuestoPrestacion
}

class Descarga{
	const property usuario
	const property producto
	const property fecha = new Date()
	
	method esDeMesActual() {
		const diaDeHoy = new Date()
		const anioActual = diaDeHoy.year()
		const mesActual = diaDeHoy.month()
		
		return fecha.year() == anioActual and fecha.month() == mesActual
	}
	
	method esDeFecha(unaFecha){
		return fecha == unaFecha
	}
}

object prepago{
	method recargo(monto) = monto*0.1
	
	method descontar(monto,usuario){
		usuario.quitarDinero(monto)
	}
}

object facturado{
	method recargo(monto) = 0
	
	method descontar(monto,usuario){
		usuario.agregarAcumulado(monto)
	}
}

