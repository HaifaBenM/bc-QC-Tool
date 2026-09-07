// AJOUTÉ (31/08/2026) — voir Tab50110.TalanQCOptionValue.al pour le
// contexte complet.
//
// Exemple d'appel côté Python (execution_planner.py / bc_api.py) :
//   GET .../api/talan/qctools/v1.0/companies({id})/optionValues
//       ?$filter=tableId eq 9 and fieldNo eq 41
// Retourne une ligne par valeur Option valide, avec son libellé exact
// dans la langue de la session BC (fieldNo = numéro de champ AL, pas
// l'ID visible dans packageFields qui est déjà le bon numéro de champ).
page 50389 "Talan QC Option Values API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'optionValue';
    EntitySetName = 'optionValues';
    SourceTable = "Talan QC Option Value";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(tableId; Rec."Table ID")
                {
                    Caption = 'Table ID';
                }
                field(fieldNo; Rec."Field No.")
                {
                    Caption = 'Field No.';
                }
                field(ordinal; Rec.Ordinal)
                {
                    Caption = 'Ordinal';
                }
                field(optionCaption; Rec."Option Caption")
                {
                    Caption = 'Option Caption';
                }
            }
        }
    }

    // AJOUTÉ (31/08/2026) — lit tableId/fieldNo depuis le $filter de la
    // requête (même principe que l'endpoint existant "Table Values API",
    // page 50106), construit un RecordRef/FieldRef sur cette table+champ,
    // et éclate FieldRef.OptionCaption() (liste ',' -séparée) en une ligne
    // par valeur — table temporaire peuplée à la volée, jamais persistée.
    trigger OnOpenPage()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TableIdFilter: Text;
        FieldNoFilter: Text;
        TableIdValue: Integer;
        FieldNoValue: Integer;
        CaptionList: Text;
        CaptionParts: List of [Text];
        CaptionPart: Text;
        Idx: Integer;
    begin
        TableIdFilter := Rec.GetFilter("Table ID");
        FieldNoFilter := Rec.GetFilter("Field No.");
        if (TableIdFilter = '') or (FieldNoFilter = '') then
            exit; // tableId et fieldNo sont obligatoires dans le $filter — sinon rien à calculer.

        if not Evaluate(TableIdValue, TableIdFilter) then
            exit;
        if not Evaluate(FieldNoValue, FieldNoFilter) then
            exit;

        // RÉVISÉ (01/09/2026) — bug de compilation trouvé : RecordRef.Open()
        // est une procédure (ne renvoie rien), pas une fonction booléenne —
        // "not RecRef.Open(...)" était donc invalide (AL0173). Passage par
        // une [TryFunction] locale, le seul moyen propre en AL de capter un
        // échec sans lever d'erreur (table inexistante par exemple).
        if not TryOpenTable(RecRef, TableIdValue) then
            exit; // table inexistante ou inaccessible — retourne une liste vide plutôt qu'une erreur.

        FieldRef := RecRef.Field(FieldNoValue);
        if Format(FieldRef.Type) <> 'Option' then begin
            RecRef.Close();
            exit; // champ pas de type Option — rien à retourner.
        end;

        CaptionList := FieldRef.OptionCaption();
        RecRef.Close();

        CaptionParts := CaptionList.Split(',');
        Idx := 0;
        foreach CaptionPart in CaptionParts do begin
            Rec.Init();
            Rec."Table ID"      := TableIdValue;
            Rec."Field No."     := FieldNoValue;
            Rec.Ordinal         := Idx;
            Rec."Option Caption":= CopyStr(CaptionPart, 1, 250);
            Rec.Insert();
            Idx += 1;
        end;
    end;

    // AJOUTÉ (01/09/2026) — [TryFunction] : seul moyen en AL de tenter une
    // opération pouvant échouer (ici, ouvrir une table qui n'existe pas
    // ou n'est pas accessible) sans laisser l'erreur remonter et casser
    // tout l'appel API — renvoie simplement false en cas d'échec.
    [TryFunction]
    local procedure TryOpenTable(var RecRef: RecordRef; TableId: Integer)
    begin
        RecRef.Open(TableId);
    end;
}
