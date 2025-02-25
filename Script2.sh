#!/bin/bash

# Archivo de datos. El 1 tiene el regitro de horas trabajadas y el 2 tiene el registro de los trabajadores
INFORME_HORAS="informe_horas.csv"
INFORME_TRABAJADORES="trabajadores.csv"

# Función que servirá para verificar si el ID existe
verificar_id() {
    grep -q "^$1," "$INFORME_TRABAJADORES"
}

# Función para calcular horas trabajadas
calcular_horas() {
    echo "Introduce tu ID:"
    read ID

    # Verificar si el ID existe gracias a la función verificar_id
    if ! verificar_id "$ID"; then
        echo "ERROR: ID no encontrado."
        exit 1
    fi

    # Obtener el nombre del trabajador por su ID, además almacenar el nombre en la variable NOMBRE
    NOMBRE=$(grep "^$ID," "$INFORME_TRABAJADORES" | cut -d ',' -f2)

    # Cálculo de horas trabajadas por día:
    echo "Horas trabajadas por día:"
    awk -F ',' -v id="$ID" '$1 == id { horas[$3] += $6 } END { for (d in horas) print d, horas[d] " horas" }' "$INFORME_HORAS"

     # Cálculo de horas trabajadas por semana:
    echo ""
    echo "Horas trabajadas por semana:"
    awk -F ',' -v id="$ID" '
    $1 == id {
        split($3, fecha, "-")
        semana = strftime("%Y-W%V", mktime(fecha[1] " " fecha[2] " " fecha[3] " 00 00 00"))
        horas[semana] += $6
    }
    END { for (s in horas) print s, horas[s] " horas" }' "$INFORME_HORAS"

    # Cálculo de horas trabajadas por mes:
    echo ""
    echo "Horas trabajadas por mes:"
    awk -F ',' -v id="$ID" '$1 == id { split($3, fecha, "-"); mes=fecha[1] "-" fecha[2]; horas[mes] += $6 } END { for (m in horas) print m, horas[m] " horas" }' "$INFORME_HORAS"
}

calcular_horas
