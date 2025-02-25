#!/bin/bash

# Archivo de registros
FILE="horas_trabajo.csv"

# Función para calcular horas por período
calcular_horas() {
    echo "Introduce tu ID:"
    read ID

    echo "Horas trabajadas por día:"
    awk -F ',' -v id="$ID" '$1 == id { horas[$3] += $6 } END { for (d in horas) print d, horas[d] " horas" }' "$FILE"

    echo ""
    echo "Horas trabajadas por semana:"
    awk -F ',' -v id="$ID" '
    $1 == id {
        split($3, fecha, "-")
        semana = strftime("%Y-W%V", mktime(fecha[1] " " fecha[2] " " fecha[3] " 00 00 00"))
        horas[semana] += $6
    }
    END { for (s in horas) print s, horas[s] " horas" }' "$FILE"

    echo ""
    echo "Horas trabajadas por mes:"
    awk -F ',' -v id="$ID" '$1 == id { split($3, fecha, "-"); mes=fecha[1] "-" fecha[2]; horas[mes] += $6 } END { for (m in horas) print m, horas[m] " horas" }' "$FILE"
}

calcular_horas
