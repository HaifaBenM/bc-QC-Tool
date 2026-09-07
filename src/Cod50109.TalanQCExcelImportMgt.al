codeunit 50390 "Talan QC Excel Import Mgt"
{
    procedure ProcessImport(var ImportReq: Record "Talan QC Excel Import Req")
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageData: Record "Config. Package Data";
        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
    begin
        ImportReq.Success := false;
        ImportReq."Error Message" := '';

        if ImportReq."Package Code" = '' then begin
            ImportReq."Error Message" := 'Package Code manquant.';
            exit;
        end;

        if not ConfigPackage.Get(ImportReq."Package Code") then begin
            ImportReq."Error Message" := StrSubstNo('Package %1 introuvable — doit déjà exister dans BC.', ImportReq."Package Code");
            exit;
        end;

        if not ImportReq."File Content".HasValue then begin
            ImportReq."Error Message" := 'Aucun contenu de fichier fourni (fileContent vide).';
            exit;
        end;

        // AJOUTÉ (31/08/2026, 6e passe) — vide données ET configuration
        // des tables du package (sans toucher au package lui-même), pour
        // qu'ImportExcel reparte sur une base vraiment vierge à chaque
        // appel, sans confirmation ni configuration résiduelle erronée.
        ConfigPackageData.SetRange("Package Code", ImportReq."Package Code");
        if not ConfigPackageData.IsEmpty() then
            ConfigPackageData.DeleteAll(true);

        ConfigPackageTable.SetRange("Package Code", ImportReq."Package Code");
        if not ConfigPackageTable.IsEmpty() then
            ConfigPackageTable.DeleteAll(true);

        Commit();

        // Copie notre champ Blob (le fichier Excel reçu par API) dans un
        // Temp Blob frais — c'est ce type précis qu'attend ImportExcel.
        ImportReq."File Content".CreateInStream(FileInStream);
        TempBlob.CreateOutStream(FileOutStream);
        CopyStream(FileOutStream, FileInStream);

        ConfigExcelExchange.ImportExcel(TempBlob);

        ImportReq.Success := true;
    end;
}