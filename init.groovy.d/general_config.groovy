import jenkins.model.*
import jenkins.AgentProtocol
import hudson.security.csrf.DefaultCrumbIssuer

def instance = Jenkins.getInstance()
instance.setNumExecutors(0)
instance.setNoUsageStatistics(true)


// Disable deprecated Jenkins node protocols
p = AgentProtocol.all()

disable_plugin_list = ["JNLP-connect", "JNLP2-connect", "JNLP3-connect"]

p.each { x ->
	if(x.name && x.name in disable_plugin_list ) {
      p.remove(x)
    }
}

instance.setCrumbIssuer(new DefaultCrumbIssuer(true))


instance.save()
