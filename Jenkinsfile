// -*- mode: groovy -*-
node ('docker') {
  def current_dir = pwd()
  // The -h nexus is a trick for testing.
  def dockerOpt = "-h nexus -v ${current_dir}/server.pem:/etc/ssl/private/server.pem:z"
  def dockerBuildOpt = "."
  def docker_name = 'nexus-haproxy'
  def image_name = "sathlan/${docker_name}"
  def ruby_env = ["PATH=${current_dir}/bin:${env.PATH}", "GEM_HOME=${current_dir}/.bundled_gems"]
  def build_image = "${image_name}:${env.BUILD_ID}"
  def myEnv

  stage('Checkout') {
    checkout scm
  }

  ansiColor() {
    stage('Prepare env') {
      withEnv(ruby_env) {
        sh "[ ! -e Gemfile.lock ] || rm Gemfile.lock"
        sh "bundle install --binstubs"
        sh "rake server.pem"
      }
    }

    stage('build image') {
      myEnv = docker.build "${image_name}:${env.BUILD_ID}", "${dockerBuildOpt}"
    }

    stage('publish image') {
      myEnv.withRun(dockerOpt) {c ->
        sh "rm -rf artifacts && mkdir -p artifacts"
        sh "docker inspect ${c.id} > artifacts/inspect.txt"
        sh "docker history ${build_image} > artifacts/history.txt"
        archive 'artifacts/'
      }
    }

    stage('test image') {
      myEnv.withRun("${dockerOpt}") {c ->
        withEnv(ruby_env + ["${docker_name.replaceAll('-','_').toUpperCase()}_ID=${c.id}", "LOCALHOST_ID=${c.id}", "DOCKER_IMAGE=${build_image}"]) {
          sh "docker logs ${c.id}"
          sh "rake spec:${docker_name}"
          sh "rake spec:localhost"
        }
      }
    }

    stage('promote') {
      timeout(time: 1, unit: 'DAYS') {
        if (askForNextStep('Deploy to GitHub ?')) {
          lock("githubPush-docker-${docker_name}") {
            githubPush("jenkins-docker-${docker_name}", 'github')
            if (askForNextStep('Release to GitHub ?')) {
              withEnv(ruby_env) {
                githubRelease()
              }
            }
          }
        }
      }
    }
  }
}
