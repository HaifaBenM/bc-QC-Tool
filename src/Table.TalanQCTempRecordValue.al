table 50103 "Talan QC Temp Record Value"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Table ID"; Integer) { Caption = 'Table ID'; }
        field(3; "Field No."; Integer) { Caption = 'Field No.'; }
        field(4; "Record Key"; Text[250]) { Caption = 'Record Key'; }
        field(5; "Value"; Text[250]) { Caption = 'Value'; }
        // Filtre alternatif au numéro de champ — le NOM AL interne d'un
        // champ (ex. "Gen. Bus. Posting Group") est stable dans toutes les
        // localisations BC, contrairement à son numéro qui peut varier.
        // Permet d'interroger par nom sans jamais coder un numéro en dur
        // côté appelant. Résolu dynamiquement par réflexion dans
        // OnOpenPage — voir PageAPI.RecordValues.al.
        field(6; "Field Name Filter"; Text[100]) { Caption = 'Field Name Filter'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
