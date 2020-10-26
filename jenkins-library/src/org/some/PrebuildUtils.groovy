package org.some

class PrebuildUtils
{
    static check(def script)
    {
        if(script._appName == "")
        {
            script.error "App name must be declared";
        }
        if(script._accountName == "group1" && script._project == "acc3")
        {
            script.error "Gps project only deploys to GPS account, set _accountName='acc3' in your Jenkinsfile ";
        }
        if(script._accountName == "acc3" && !(script._project == "acc3"))
        {
            script.error "Gps project only deploys to GPS account and vice versa, set _accountName and _projectName in your Jenkinsfile";
        }
        if (!(script._accountName == "acc3" || script._accountName == "group1"))
        {
            script.error "Account can only be acc3 or group1";
        }
        if (script._useLoadBalancer && (7 + script._appName.length()) >= 32)
        {
            script.error "Name is too long! Keep it under 25 characters";
        }
        
    }

    static getEnvironmentName(def script)
    {
      if(script.env.BRANCH_NAME == "master")
      {
             return "production";
      }
      else 
      {
            return script.env.BRANCH_NAME;
      } 
   }
}

