package org.some;

class NotificationsUtils
{
    static Send(def pipeline,String buildStatus = 'STARTED', String msg = '|') {

        buildStatus =  buildStatus ?: 'SUCCESSFUL'

        // Default values
        String color = 'RED'
        String colorCode = '#FF0000'
        String intergrationTokenSlack = 'hh1dkdlkasjdlaskjrN1t'
        String channelName =  'alerts_echo_ci'

        String subject = "${buildStatus}: Job '${pipeline.env.JOB_NAME} [${pipeline.env.BUILD_NUMBER}]'"
        String summary = "${msg} -- ${subject} -- ${pipeline.env.BUILD_URL}"

        // Override default values based on build status
        if (buildStatus == 'STARTED') {
            color = 'BLUE'
            colorCode = '#4169E1'
        } else if (buildStatus == "SUCCESS") {
            color = 'GREEN'
            colorCode = '#3CB371'
        } else if (buildStatus == "FAILURE"){
            color = 'RED'
            colorCode = '#FF0000'
        } else if (buildStatus == "IS_FRIDAY"){
            color = 'RED'
            colorCode = '#FF0000'
        } else if (buildStatus == "UNSTABLE"){
            color = 'YELLOW'
            colorCode = '#FFFF00'
            summary = "${subject}"
        } else if (buildStatus == "VERIFY"){
            color = 'YELLOW'
            colorCode = '#FFC500'
            summary = "${subject}"
        } else if (buildStatus == "PROMOTE"){
            color = 'YELLOW'
            colorCode = '#FFFF00'
            summary = "${subject}"
        } else {
            color = 'RED'
            colorCode = '#FF0000'
            summary = "${subject}"
        }

        // Send notifications
        pipeline.slackSend (color: colorCode, token: intergrationTokenSlack, channel: channelName, message: summary)
        }
}