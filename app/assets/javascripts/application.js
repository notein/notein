// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require trix
//= require rails-ujs
//= require_tree .

(function() {
  const application = Stimulus.Application.start()
  
  application.register("clipboard", class extends Stimulus.Controller {
  
    connect() {
      if (document.queryCommandSupported("copy")) {
        this.element.classList.add("clipboard--supported")
      }
    }
  
    copy() {
      const target = this.targets.find("source")
      target.select()
      document.execCommand("copy")
    }

  })
  
  application.register("dropdown", class extends Stimulus.Controller {
 
    open() {
      const target = this.targets.find("menu")
      target.classList.remove("hidden")
      target.classList.add("visible")
    }    
    
    close() {
      const target = this.targets.find("menu")
      target.classList.remove("visible")
      target.classList.add("hidden")
    }

  })
  
  application.register("search", class extends Stimulus.Controller {
 
    fire() {
      const username = this.element.getAttribute("data-username")
      if (username != "") {
        var query = "/" + username
      } else {
        var query = username
      }
      const target = this.targets.find("field")
      if (event.which == 13) {
        var term = target.value //.trim()
        if (term[0] == "#") {
          location.href = query + "/tags" + term.replace(/\s/g, "").replace(/#/g,"/");
        } else {
          location.href = query +  "/search/" + term;
        }
      }
    }    

  })
})()

// avoid pasting images from other sources

addEventListener("trix-attachment-add", function(event) {
  if (!event.attachment.file) {
    event.attachment.remove()
  }
})