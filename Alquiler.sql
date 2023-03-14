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

  --INTO select Punto 2
  v_id_modelo vehiculos.id_modelo%type;
  v_precio_diario modelos.precio_cada_dia%type;
  v_capacidad_deposito modelos.capacidad_deposito%type;
  v_tipo_combustible modelos.tipo_combustible%type;
  v_precio_litro precio_combustible.precio_por_litro%type;

  --INTO select Punto 3
  v_fecha_ini reservas.fecha_ini%type;
  v_fecha_fin reservas.fecha_fin%type;


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

  /*dbms_output.put_line(v_id_modelo);
  exception
    when no_data_found then
      dbms_output.put_line('No se ha encontrado ningun vehiculo con matricula ' || arg_matricula);
    */
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

end;
