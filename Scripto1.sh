#!/bin/bash

# Archivos de datos
INFORME_HORAS="informe_horas.csv"
INFORME_TRABAJADORES="trabajadores.csv"

# Función para verificar si el ID existe
verificar_id() {
    grep -q "^$1," "$INFORME_TRABAJADORES"
}

# Función para obtener el nombre del trabajador por su ID
obtener_nombre() {
    grep "^$1," "$INFORME_TRABAJADORES" | cut -d ',' -f2
}

# Función para registrar entrada
registrar_entrada() {
    echo "Introduce tu ID:"
    read ID

    # Verificar si el ID existe
    if ! verificar_id "$ID"; then
        echo "ERROR: ID no encontrado. Contacta con administración."
        exit 1
    fi

    NOMBRE=$(obtener_nombre "$ID")
    FECHA=$(date +"%Y-%m-%d")
    HORA_ENTRADA=$(date +"%H:%M:%S")

    # Verificar si ya hay una entrada registrada hoy
    if grep -q "^$ID,$NOMBRE,$FECHA" "$INFORME_HORAS"; then
        echo "Ya tienes una entrada registrada hoy."
    else
        echo "$ID,$NOMBRE,$FECHA,$HORA_ENTRADA,," >> "$INFORME_HORAS"
        echo "Entrada registrada: $HORA_ENTRADA"
    fi
}

# Función para registrar salida
registrar_salida() {
    echo "Introduce tu ID:"
    read ID

    # Verificar si el ID existe
    if ! verificar_id "$ID"; then
        echo "ERROR: ID no encontrado."
        exit 1
    fi

    FECHA=$(date +"%Y-%m-%d")
    HORA_SALIDA=$(date +"%H:%M:%S")

    # Buscar si el usuario tiene una entrada sin salida registrada
    if grep -q "^$ID,.*,$FECHA,[0-9:]*,," "$INFORME_HORAS"; then
        # Extraer la línea completa
        LINEA=$(grep "^$ID,.*,$FECHA,[0-9:]*,," "$INFORME_HORAS")
        HORA_ENTRADA=$(echo "$LINEA" | cut -d ',' -f 4)

        # Calcular el total de horas trabajadas
        HORAS_TRABAJADAS=$(awk -v h1="$HORA_ENTRADA" -v h2="$HORA_SALIDA" \
            'BEGIN{
                split(h1,a,":"); split(h2,b,":");
                t1 = a[1]*3600 + a[2]*60 + a[3];
                t2 = b[1]*3600 + b[2]*60 + b[3];
                diff = (t2 - t1) / 3600;
                printf "%.2f", diff;
            }')

        # Actualizar la línea en el archivo
        sed -i "s|^$ID,.*,$FECHA,$HORA_ENTRADA,,|$ID,$(echo "$LINEA" | cut -d ',' -f 2-4),$HORA_SALIDA,$HORAS_TRABAJADAS|" "$INFORME_HORAS"

        echo "Salida registrada: $HORA_SALIDA"
        echo "Total de horas trabajadas hoy: $HORAS_TRABAJADAS"
    else
        echo "No tienes una entrada registrada para hoy."
    fi
}

# Menú
echo "Selecciona una opción:"
echo "1) Registrar entrada"
echo "2) Registrar salida"
read OPCION

case $OPCION in
    1) registrar_entrada ;;
    2) registrar_salida ;;
    *) echo "Opción no válida." ;;
esac
