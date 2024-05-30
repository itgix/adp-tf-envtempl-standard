<h2>Purpose</h2>

<p>alb-controller, and external-dns controller provision AWS resources introducing dependencies, which prevent terraform destroy to complete.
This script will disable ArgoCD applications self-healing, starting with app-of-apps, and then remove all Ingress resources with waiting for finalizers enabled.
Deleting Ingress resources will cause said controllers to remove AWS resources they manage.</p>

<h3>Explicit app-of-apps supported:</h3>
<ul>
<li>infra-services</li>
<li>app-auto-deploy</li>
</ul>

<p>Application resources belonging to argocd namespace supported only.</p>

<p>You must have working kubectl access to desired cluster.</p>
<p>**Please make sure kubeconfig is not pointing to another environment before running the script. It is destructive.**</p>
