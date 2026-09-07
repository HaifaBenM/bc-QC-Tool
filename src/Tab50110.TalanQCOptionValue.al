// AJOUTÉ (31/08/2026) — demande Rami : remplacer _OPTION_VALUES (liste
// codée en dur côté Python, découverte au coup par coup à chaque nouvelle
// table rencontrée — cause du point aveugle sur Pays/Région/Format
// adresse aujourd'hui) par une vraie source dynamique. AL expose
// nativement FieldRef.OptionCaption() : la liste des libellés valides
// d'un champ Option, dans la langue de la session — exactement ce que
// l'outil doit comparer aux valeurs du fichier client.
//
// Nouvel endpoint isolé, séparé de PageAPI.PackageFields.al existant
// (jamais modifié — trop risqué de le retoucher sans voir son contenu
// exact, à ce stade du projet).
table 50110 "Talan QC Option Value"
{
    Caption = 'Talan QC Option Value';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(3; Ordinal; Integer)
        {
            Caption = 'Ordinal';
            DataClassification = SystemMetadata;
        }
        field(4; "Option Caption"; Text[250])
        {
            Caption = 'Option Caption';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Table ID", "Field No.", Ordinal)
        {
            Clustered = true;
        }
    }
}
