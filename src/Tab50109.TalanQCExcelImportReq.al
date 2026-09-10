// AJOUTÉ (27/08/2026) — Option 1 des chantiers post-démo (bouton "Intégrer
// directement dans BC") : l'endpoint standard de l'API Automation
// (configurationPackages/file/content) attend un fichier .rapidstart
// (format interne compressé), PAS un fichier Excel brut — confirmé par la
// documentation officielle Microsoft et un article de la communauté BC.
// C'est pour ça que l'import échouait systématiquement avec "The archive
// entry was compressed using an unsupported compression method" : BC
// essayait de lire notre xlsx comme s'il s'agissait d'un flux GZip.
//
// Cette table + la page API + le codeunit qui suivent créent un point
// d'entrée custom qui reproduit ce que fait le bouton "Importer d'Excel"
// de la fiche Configuration Package, mais appelable par API — en
// contournant la limite de l'endpoint standard.
table 50109 "Talan QC Excel Import Req"
{
    Caption = 'Talan QC Excel Import Request';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = SystemMetadata;
        }
        field(3; "File Content"; Blob)
        {
            Caption = 'File Content';
            DataClassification = SystemMetadata;
            // Les pages API exposent automatiquement un champ Blob en
            // base64 dans le JSON (POST/PATCH), ou en flux binaire via
            // le lien média correspondant — voir PageAPI.
            // ExcelImportRequest.al.
        }
        field(10; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Import Status Debug"; Text[100])
        {
            // AJOUTÉ (01/09/2026) — diagnostic : valeur RÉELLE du champ
            // "Import Status" du package juste après notre tentative de le
            // fixer explicitement à Completed — pour voir directement dans
            // l'outil si ça a fonctionné, sans avoir besoin d'aller
            // vérifier manuellement dans l'interface BC à chaque test.
            Caption = 'Import Status Debug';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
