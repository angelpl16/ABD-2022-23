-- Implementado por Angel Palacios López
create or replace procedure alquilar(arg_NIF_cliente varchar,
  arg_matricula varchar, arg_fecha_ini date, arg_fecha_fin date) is
  
  dias_negativos exception;
  vehiculo_no_existe exception;
  
  PRAGMA EXCEPTION_INIT (dias_negativos, -20003);
  PRAGMA EXCEPTION_INIT (vehiculo_no_existe, -20002);
  num_dias integer;
  
  --INTO select Punto 2
  v_id_modelo vehiculos.id_modelo%type;
  v_precio_diario modelos.precio_cada_dia%type;
  v_capacidad_deposito modelos.capacidad_deposito%type;
  v_tipo_combustible modelos.tipo_combustible%type;
  v_precio_litro precio_combustible.precio_por_litro%type;
  
    
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
  select vehiculos.id_modelo,modelos.precio_cada_dia,modelos.capacidad_deposito,
  modelos.tipo_combustible,precio_combustible.precio_por_litro
  into v_id_modelo,v_precio_diario,v_capacidad_deposito,v_tipo_combustible,v_precio_litro
  from vehiculos natural join modelos natural join precio_combustible
  where arg_matricula = vehiculos.matricula;
  
  dbms_output.put_line(v_id_modelo);
  exception
    when no_data_found then
      dbms_output.put_line('No se ha encontrado ningun vehiculo con matricula ' || arg_matricula);
      
--
  
end;
/