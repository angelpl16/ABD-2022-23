-- Ángel Palacios López // ABD // Curso 22-23

create or replace procedure alquilar(arg_NIF_cliente varchar,
  arg_matricula varchar, arg_fecha_ini date, arg_fecha_fin date) is
  
  dias_negativos exception;
  vehiculo_no_existe exception;
  vehiculo_ocupado exception;

  PRAGMA EXCEPTION_INIT (dias_negativos, -20003);
  PRAGMA EXCEPTION_INIT (vehiculo_no_existe, -20002);
  PRAGMA EXCEPTION_INIT (vehiculo_ocupado, -20004);
  
  num_dias integer;
  cliente_existe boolean := false;

  --INTO select Punto 2
  v_id_modelo vehiculos.id_modelo%type;
  v_precio_diario modelos.precio_cada_dia%type;
  v_capacidad_deposito modelos.capacidad_deposito%type;
  v_tipo_combustible modelos.tipo_combustible%type;
  v_precio_litro precio_combustible.precio_por_litro%type;

  --INTO select Punto 3
  v_fecha_ini reservas.fecha_ini%type;
  v_fecha_fin reservas.fecha_fin%type;
  
  --INTO select Punto 4
  cliente clientes%rowtype;
  

begin

--PUNTO 1
  if arg_fecha_fin is NOT NULL then 
    num_dias:=arg_fecha_fin-arg_fecha_ini;
  end if;

  if (num_dias <= 0) then
    ROLLBACK;
    raise_application_error(-20003,'El numero de dias sera mayor a 0');
  end if;

  --PUNTO 2
  select id_modelo,precio_cada_dia,capacidad_deposito,tipo_combustible,precio_por_litro
  into v_id_modelo,v_precio_diario,v_capacidad_deposito,v_tipo_combustible,v_precio_litro
  from vehiculos natural join modelos natural join precio_combustible
  where arg_matricula = vehiculos.matricula;
  
      
  
  
    
--PUNTO 3

-- Suponemos que para llegar a este punto la consulta del Punto 2 ha devuelto informacion

    select fecha_ini, fecha_fin
    into v_fecha_ini,v_fecha_fin
    from vehiculos natural join reservas
    where arg_matricula = matricula;

    if (arg_fecha_ini < v_fecha_fin) or (arg_fecha_fin > v_fecha_ini) or (arg_fecha_ini < v_fecha_ini and arg_fecha_fin >
    v_fecha_fin) or (arg_fecha_ini > v_fecha_ini and arg_fecha_fin < v_fecha_fin) then
        ROLLBACK;
        raise_application_error(-20004,'El vehiculo no esta disponible');
    end if;
    
    
-- PUNTO 4

/* Antes de añadir un usuario se debe comprobar que el usuario no existe en el sistema
   Para comprobar la existencia, comprobamos si el NIF del usuario existe en alguna tabla, si no existiese no se podría realizar
   la reserva */
   
   select * into cliente
   from clientes
   where NIF = arg_NIF_cliente;
   
   cliente_existe := true;
   
   
   INSERT INTO reservas(idReserva, cliente,matricula,fecha_ini,fecha_fin) 
   VALUES(seq_reservas.nextval, arg_NIF_cliente, arg_matricula, arg_fecha_ini, arg_fecha_fin);
   
   /* Pregunta 1 
   En el procedimiento alquila(argumentos) se comprueba lo siguiente:
   Paso 1: Que la fecha pasada por el usuario tiene como inicio una fecha posterior a la final
   Paso 2: Que existe un coche con la matricula proporcionada
   Paso 3: No hay solapamiento del vehiculo seleccionado
   Paso 4: El cliente existe en el sistema
   
   Aparentemente la informacion parece fiable tras el ultimo select
   
   
   Pregunta 2
   La situacion más parecida podría darse con el siguiente ejemplo:
   -- SESION 1: Se realiza el insert (matricula: 1111AAA; fecha 1/1/23 - 2/1/23) y con ello se realiza un bloqueo de escritura
   -- SESION 2: Se realiza un insert (matricula: 1111AAA; fecha 1/1/23 - 3/1/23) . Se pausa insertar informacion (Bloqueo Escritura Sesion 1)
   -- SESION 1: Se realiza un select, se muestra la informacion añadida en el select de la sesión 1
    
    Podría haberse añadido al superar los controles
   */
 
   EXCEPTION
    WHEN no_data_found THEN 
        rollback;
        IF cliente_existe = true THEN
            raise_application_error(-20002, 'Vehiculo inexistente');
        ELSE
            raise_application_error(-20001, 'Cliente inexistente');
        END IF;

end;