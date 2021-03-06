pipeline {

    agent any

    options {
        ansiColor('xterm')
    }

    environment {
        HAXELIB_CACHE = '../../.haxelib_cache/ArpEngine/.haxelib'
    }

    stages {
        stage('prepare') {
            steps {
                githubNotify(context: 'swf', description: '', status: 'PENDING');
                githubNotify(context: 'swf_heaps', description: '', status: 'PENDING');
                githubNotify(context: 'js', description: '', status: 'PENDING');
                githubNotify(context: 'js_heaps', description: '', status: 'PENDING');
                // githubNotify(context: 'js_sys', description: '', status: 'PENDING');
                githubNotify(context: 'neko_sys', description: '', status: 'PENDING');
                githubNotify(context: 'cpp_sys', description: '', status: 'PENDING');
                sh "haxelib newrepo"
                sh "haxelib git arp_ci https://github.com/ArpEngine/Arp-ci master --always"
                sh "haxelib run arp_ci sync"
            }
        }

        stage('swf') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=swf ARPCI_BACKEND=flash haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/swf_flash.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }

        stage('swf_heaps') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=swf ARPCI_BACKEND=heaps haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/swf_heaps.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }

        stage('js') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=js ARPCI_BACKEND=js haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/js_js.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }

        stage('js_heaps') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=js ARPCI_BACKEND=heaps haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/js_heaps.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }

        /*
        stage('js_sys') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=js ARPCI_BACKEND=sys haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/js_sys.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }
        */

        stage('neko_sys') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=neko ARPCI_BACKEND=sys haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/neko_sys.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }

        stage('cpp_sys') {
            steps {
                catchError {
                    sh "ARPCI_PROJECT=ArpEngine ARPCI_TARGET=cpp ARPCI_BACKEND=sys haxelib run arp_ci test"
                }
            }
            post {
                always { junit(testResults: "bin/junit/cpp_sys.xml", keepLongStdio: true); }
                success { githubNotify(context: "${STAGE_NAME}", description: '', status: 'SUCCESS'); }
                unsuccessful { githubNotify(context: "${STAGE_NAME}", description: '', status: 'FAILURE'); }
            }
        }
    }
}
