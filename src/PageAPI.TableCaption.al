page 50107 "Talan QC Table Caption API"
{
    // Résolution dynamique du libellé BC d'une table (RecRef.Caption),
    // en français (GLOBALLANGUAGE 1036, même dette technique que
    // PageAPI.PackageFields.al — à rendre configurable un jour, voir
    // notes du 17/07/2026).
    //
    // GET /api/talan/qctools/v1.0/companies({id})/tableCaptions
    //     ?$filter=tableId eq 15
    //
    // Remplace côté Python le dictionnaire statique
    // master_data_config.REFERENCE_TABLES comme source PRIORITAIRE
    // (fallback statique conservé si l'appel échoue ou si la table
    // n'existe pas / n'est pas accessible).
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'tableCaption';
    EntitySetName = 'tableCaptions';
    SourceTable = "Talan QC Temp Table Caption";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(tableId; Rec."Table ID")
                {
                    Caption = 'tableId', Locked = true;
                }
                field(tableCaption; Rec."Table Caption")
                {
                    Caption = 'tableCaption', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        RecRef: RecordRef;
        TableIdFilter: Integer;
        FilterText: Text;
    begin
        // Même mécanique éprouvée que PageAPI.TableValues.al : le
        // framework API applique le $filter OData sur Rec AVANT
        // OnOpenPage, donc GetFilter() fonctionne malgré
        // SourceTableTemporary = true.
        FilterText := Rec.GetFilter("Table ID");
        if FilterText = '' then
            exit;
        if not Evaluate(TableIdFilter, FilterText) then
            exit;
        if TableIdFilter = 0 then
            exit;

        GLOBALLANGUAGE(1036); // French (France) — cohérent avec le reste de l'outil

        // CORRIGÉ (AL0173) : RecordRef.Open() est une procédure void, pas
        // une fonction booléenne — "not RecRef.Open(...)" est invalide en
        // AL. Pattern standard : TryFunction locale pour rendre l'échec
        // testable (table inexistante/inaccessible = ID invalide, pas une
        // exception à laisser remonter).
        if not TryOpenTable(RecRef, TableIdFilter) then
            exit;

        Rec.Init();
        Rec."Table ID" := TableIdFilter;
        Rec."Table Caption" := CopyStr(RecRef.Caption, 1, MaxStrLen(Rec."Table Caption"));
        Rec.Insert();

        RecRef.Close();
    end;

    [TryFunction]
    local procedure TryOpenTable(var RecRef: RecordRef; TableIdFilter: Integer)
    begin
        RecRef.Open(TableIdFilter);
    end;
}
