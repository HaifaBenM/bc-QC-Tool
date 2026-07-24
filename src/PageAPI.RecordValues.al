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
// DEUX FAÇONS DE FILTRER LE CHAMP — jamais de numéro codé en dur requis :
//
// 1) Par nom de champ AL (recommandé, 100% dynamique) — le nom interne
//    d'un champ ("Gen. Bus. Posting Group") est stable dans toutes les
//    localisations BC, seule sa légende affichée est traduite. Résolu par
//    réflexion à chaque appel, jamais figé nulle part :
//      GET .../recordValues?$filter=tableId eq 15
//          and fieldNameFilter eq 'Gen. Prod. Posting Group'
//
// 2) Par numéro de champ, si déjà connu (plus rapide, un aller-retour de
//    moins) :
//      GET .../recordValues?$filter=tableId eq 15 and fieldNo eq 38
//
// Réponse : une ligne par enregistrement qui a une valeur non vide sur ce
// champ — recordKey = clé primaire (No. du compte pour la table 15),
// value = la valeur du champ, fieldNo = le numéro résolu (utile même en
// mode 1, pour audit/cache côté appelant). Un enregistrement absent du
// résultat = champ vide (même logique que tableValues : on ne matérialise
// que le non-vide, plus léger).
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
            field(fieldNameFilter; Rec."Field Name Filter")
            { Caption = 'fieldNameFilter', Locked = true; }
        }
    }

    trigger OnOpenPage()
    var
        TableIdFilter: Integer;
        FieldNoFilter: Integer;
        FieldNameFilterText: Text;
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
        FilterText := Rec.GetFilter("Table ID");
        if FilterText = '' then exit;
        Evaluate(TableIdFilter, FilterText);
        if TableIdFilter = 0 then exit;

        // fieldNo explicite a priorité s'il est fourni ; sinon on résout
        // dynamiquement par nom — jamais les deux filtres vides.
        FilterText := Rec.GetFilter("Field No.");
        if FilterText <> '' then
            Evaluate(FieldNoFilter, FilterText)
        else
            FieldNoFilter := 0;

        FieldNameFilterText := Rec.GetFilter("Field Name Filter");

        if (FieldNoFilter = 0) and (FieldNameFilterText = '') then
            exit;

        RecRef.Open(TableIdFilter);

        // Résolution dynamique par nom AL — parcourt les champs de la
        // table et compare leur Name (stable inter-localisations, pas leur
        // Caption traduite) au filtre demandé.
        if (FieldNoFilter = 0) and (FieldNameFilterText <> '') then
            for i := 1 to RecRef.FieldCount() do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.Name = FieldNameFilterText then begin
                    FieldNoFilter := FldRef.Number;
                    break;
                end;
            end;

        if FieldNoFilter = 0 then begin
            RecRef.Close();
            exit;  // ni fieldNo valide ni nom de champ résolu — rien à faire
        end;

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
