Comme proposé je n'ai pas couvert de tests tout le contrat, en revanche j'ai démarré avec l'optique de tester des choses cohérentes avec l'usage et les limites :

- On peut ajouter un votant,
- On ne peut pas ajouter un votant deux fois,
- On peut démarrer la phase de proposals,
- On ne peut pas ajouter un votant après avoir démarré la phase de proposals,
- ...

Voilà la démarche. Par ailleurs, en écrivant les tests j'ai détecté une amélioration qui pourrait être faite dans l'implémentation du contrat : revert si l'on souhaite démarrer la phase de proposals alors qu'il n'y a pas de votants inscrits.
