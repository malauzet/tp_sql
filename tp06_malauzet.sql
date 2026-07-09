-- 2) Désactivation du SAFE mode
SET SQL_SAFE_UPDATES = 0;

-- 3) a. Mettez en minuscules la désignation de l’article dont l’identifiant est 2
UPDATE ARTICLE
SET DESIGNATION = LOWER(DESIGNATION)
WHERE ID = 2;

-- 3) b. Mettez en majuscules les désignations de tous les articles dont le prix est strictement supérieur à 10€
UPDATE ARTICLE
SET DESIGNATION = UPPER(DESIGNATION)
WHERE PRIX > 10;

-- 3) c. Baissez de 10% le prix de tous les articles qui n’ont pas fait l’objet d’une commande.
UPDATE ARTICLE A
SET PRIX = PRIX * 0.9
WHERE NOT EXISTS (
	SELECT *
	FROM COMPO C
	WHERE C.ID_ART = A.ID
);

-- 3) d. Une erreur s’est glissée dans les commandes concernant Française d’imports.
-- Les chiffres en base ne sont pas bons. Il faut doubler les quantités de tous les articles commandés à cette société.
UPDATE COMPO C
SET QTE = QTE * 2
WHERE EXISTS (
	SELECT *
	FROM BON B
		JOIN FOURNISSEUR F ON F.ID = B.ID_FOU
	WHERE B.ID = C.ID_BON AND F.NOM = 'Française d''Imports'
);

-- 3) e. Mettez au point une requête update qui permette de supprimer les éléments entre parenthèses dans les désignations.
-- Il vous faudra utiliser des fonctions comme substring et position.
UPDATE ARTICLE
SET DESIGNATION = SUBSTRING(DESIGNATION, 1, POSITION('(' IN DESIGNATION) - 1)
WHERE DESIGNATION LIKE '%(%';