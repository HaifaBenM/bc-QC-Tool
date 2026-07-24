// ═══════════════════════════════════════════════════════════════════════
// Complète "Talan QC Table Values API" (page 50106) qui ne retourne QUE
// l'ensemble dédupliqué des valeurs présentes dans un champ, sur toute une
// table — utile pour "quels codes existent", pas pour "quelle est la
// valeur de ce champ pour CET enregistrement précis".
//
// Cas d'usage concret (24/07/2026, outil BC Data Quality Control) : savoir
// si le compte G/L 77110001 a bien son champ "Gen. Prod. Posting Group"
// rempli — tableValues(tableId=15, fieldNo=X) donnerait l'ensemble des
// groupes produit existants sur TOUS les comptes, jamais lequel appartient
// à quel compte.
//
// Utilisation OData, une fois publiée :
//   GET .../api/talan/qctools/v1.0/companies({id})/recordValues
//       ?$filter=tableId eq 15 and fieldNo eq 38
//   (remplacer 38 par le numéro réel du champ "Gen. Prod. Posting Group"
//   sur la table 15 dans VOTRE version BC — vérifier via l'objet AL
//   "G/L Account" ou le Field Explorer, le numéro peut varier selon
//   localisation/version)
//
// Réponse : une ligne par compte GL qui a une valeur non vide sur ce
// champ — recordKey = "No." du compte, value = la valeur du champ.
// Un compte absent du résultat = champ vide pour ce compte (même logique
// que tableValues : on ne matérialise que le non-vide, plus léger).
// ═══════════════════════════════════════════════════════════════════════

page 50104 "Talan QC Record Values API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'recordValue';
    EntitySetName = 'recordValues';
    SourceTable = "Talan QC Temp Record Value";
    SourceTableTemporary = true;
    ODataKeyFields = "Entry No.";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(entryNo; Rec."Entry No.")
            { Caption = 'entryNo', Locked = true; }
            field(tableId; Rec."Table ID")
            { Caption = 'tableId', Locked = true; }
            field(fieldNo; Rec."Field No.")
            { Caption = 'fieldNo', Locked = true; }
            field(recordKey; Rec."Record Key")
            { Caption = 'recordKey', Locked = true; }
            field(value; Rec.Value)
            { Caption = 'value', Locked = true; }
        }
    }

    trigger OnOpenPage()
    var
        TableIdFilter: Integer;
        FieldNoFilter: Integer;
        FilterText: Text;
        RecRef: RecordRef;
        FldRef: FieldRef;
        KeyRef: KeyRef;
        KeyFldRef: FieldRef;
        i: Integer;
        EntryNo: Integer;
        ValText: Text;
        KeyText: Text;
    begin
        // Mêmes règles de filtrage que Talan QC Table Values API (page
        // 50106) — tableId et fieldNo obligatoires, sinon on ne retourne
        // rien plutôt que de scanner toute la base par erreur.
        FilterText := Rec.GetFilter("Table ID");
        if FilterText = '' then exit;
        Evaluate(TableIdFilter, FilterText);
        if TableIdFilter = 0 then exit;

        FilterText := Rec.GetFilter("Field No.");
        if FilterText = '' then exit;
        Evaluate(FieldNoFilter, FilterText);
        if FieldNoFilter = 0 then exit;

        RecRef.Open(TableIdFilter);

        KeyRef := RecRef.KeyIndex(1);

        EntryNo := 0;
        if RecRef.FindSet() then
            repeat
                // Clé primaire formatée en texte — concatène tous les
                // champs de la première clé si composite (ex. ligne de
                // package : Package Code + Table ID), séparés par "|".
                KeyText := '';
                for i := 1 to KeyRef.FieldCount() do begin
                    KeyFldRef := KeyRef.FieldIndex(i);
                    KeyFldRef := RecRef.Field(KeyFldRef.Number);
                    if KeyText <> '' then
                        KeyText += '|';
                    KeyText += Format(KeyFldRef.Value);
                end;

                FldRef := RecRef.Field(FieldNoFilter);
                ValText := Format(FldRef.Value);

                if ValText <> '' then begin
                    EntryNo += 1;
                    Rec.Init();
                    Rec."Entry No." := EntryNo;
                    Rec."Table ID" := TableIdFilter;
                    Rec."Field No." := FieldNoFilter;
                    Rec."Record Key" := CopyStr(KeyText, 1, MaxStrLen(Rec."Record Key"));
                    Rec.Value := CopyStr(ValText, 1, MaxStrLen(Rec.Value));
                    Rec.Insert();
                end;
            until RecRef.Next() = 0;

        RecRef.Close();
    end;
}
