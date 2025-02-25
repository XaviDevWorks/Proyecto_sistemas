#!/bin/bash

# Archivo de datos
FILE_HORAS="horas_trabajo.csv"
FILE_TRABAJADORES="trabajadores.csv"

# Función para verificar si el ID existe
verificar_id() {
    grep -q "^$1," "$FILE_TRABAJADORES"
}

# Función para calcular horas trabajadas
calcular_horas() {
    echo "Introduce tu ID:"
    read ID

    # Verificar si el ID existe
    if ! verificar_id "$ID"; then
        echo "❌ ERROR: ID no encontrado."
        exit 1
    fi

    NOMBRE=$(grep "^$ID," "$FILE_TRABAJADORES" | cut -d ',' -f2)

    echo "📊 Horas trabajadas por día:"
    awk -F ',' -v id="$ID" '$1 == id { horas[$3] += $6 } END { for (d in horas) print d, horas[d] " horas" }' "$FILE_HORAS"

    echo ""
    echo "📆 Horas trabajadas por semana:"
    awk -F ',' -v id="$ID" '
    $1 == id {
        split($3, fecha, "-")
        semana = strftime("%Y-W%V", mktime(fecha[1] " " fecha[2] " " fecha[3] " 00 00 00"))
        horas[semana] += $6
    }
    END { for (s in horas) print s, horas[s] " horas" }' "$FILE_HORAS"

    echo ""
    echo "📅 Horas trabajadas por mes:"
    awk -F ',' -v id="$ID" '$1 == id { split($3, fecha, "-"); mes=fecha[1] "-" fecha[2]; horas[mes] += $6 } END { for (m in horas) print m, horas[m] " horas" }' "$FILE_HORAS"
}

calcular_horas
