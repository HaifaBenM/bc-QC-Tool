// AJOUTÉ (27/08/2026) — voir Tab50109.TalanQCExcelImportReq.al pour le
// contexte complet.
//
// RÉVISÉ (31/08/2026, 3e passe) — bug réel confirmé : "Read called with
// an open stream or textreader" se produit dès que création (POST) et
// dépôt du contenu Blob se font dans LA MÊME requête. Découpé en 2
// appels distincts, comme pour l'endpoint standard configurationPackages/
// file :
//   1. POST — crée l'enregistrement avec juste packageCode (Blob vide,
//      OnInsertRecord ne fait rien de spécial).
//   2. PATCH — dépose ensuite fileContent séparément sur l'enregistrement
//      déjà créé (via fileContent@odata.mediaEditLink, en binaire brut) ;
//      c'est OnModifyRecord qui déclenche le traitement réel (ImportExcel),
//      une fois le Blob effectivement en place.
//
// Exemple d'appel côté Python (bc_api.py, import_excel_via_al_endpoint) :
//   1. POST .../api/talan/qctools/v1.0/companies({id})/excelImportRequests
//      { "packageCode": "MDD-PAYS" }
//   2. PATCH sur le fileContent@odata.mediaEditLink retourné à l'étape 1,
//      Content-Type: application/octet-stream, corps = octets bruts du xlsx.
//   3. GET sur l'entité pour lire success/errorMessage.
page 50109 "Talan QC Excel Import API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'excelImportRequest';
    EntitySetName = 'excelImportRequests';
    SourceTable = "Talan QC Excel Import Req";
    DelayedInsert = true;
    Editable = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(packageCode; Rec."Package Code")
                {
                    Caption = 'Package Code';
                }
                field(fileContent; Rec."File Content")
                {
                    Caption = 'File Content';
                }
                field(success; Rec.Success)
                {
                    Caption = 'Success';
                }
                field(errorMessage; Rec."Error Message")
                {
                    Caption = 'Error Message';
                }
                field(importStatusDebug; Rec."Import Status Debug")
                {
                    Caption = 'Import Status Debug';
                }
            }
        }
    }

    // Création "vide" : ne touche jamais au Blob ici, évite tout conflit
    // de flux au moment de l'insertion.
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec."Error Message" := '';
        exit(true);
    end;

    // C'est ICI, au moment du PATCH séparé qui dépose fileContent sur un
    // enregistrement déjà créé, que le traitement réel se déclenche.
    trigger OnModifyRecord(): Boolean
    var
        ImportMgt: Codeunit "Talan QC Excel Import Mgt";
    begin
        ImportMgt.ProcessImport(Rec);
        exit(true);
    end;
}
