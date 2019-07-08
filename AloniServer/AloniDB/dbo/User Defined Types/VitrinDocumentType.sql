CREATE TYPE VitrinDocumentType as table 
(
	fk_document_id uniqueidentifier,
	isPrime bit
)