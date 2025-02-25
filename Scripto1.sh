#!/bin/bash

# Archivo donde se guardarán los registros
FILE="horas_trabajo.csv"

# Función para registrar entrada
registrar_entrada() {
    echo "Introduce tu ID:"
    read ID
    echo "Introduce tu nombre:"
    read NOMBRE
    FECHA=$(date +"%Y-%m-%d")
    HORA_ENTRADA=$(date +"%H:%M:%S")

    # Verificar si el ID ya tiene una entrada sin salida registrada
    if grep -q "^$ID,$NOMBRE,$FECHA" "$FILE"; then
        echo "Ya tienes una entrada registrada para hoy."
    else
        echo "$ID,$NOMBRE,$FECHA,$HORA_ENTRADA,," >> "$FILE"
        echo "Entrada registrada: $HORA_ENTRADA"
    fi
}

# Función para registrar salida
registrar_salida() {
    echo "Introduce tu ID:"
    read ID
    FECHA=$(date +"%Y-%m-%d")
    HORA_SALIDA=$(date +"%H:%M:%S")

    # Buscar la línea de entrada sin salida registrada
    if grep -q "^$ID,.*,$FECHA,[0-9:]*,," "$FILE"; then
        # Extraer la línea completa
        LINEA=$(grep "^$ID,.*,$FECHA,[0-9:]*,," "$FILE")
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
        sed -i "s|^$ID,.*,$FECHA,$HORA_ENTRADA,,|$ID,$(echo "$LINEA" | cut -d ',' -f 2-4),$HORA_SALIDA,$HORAS_TRABAJADAS|" "$FILE"

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
