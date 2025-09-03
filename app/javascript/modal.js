// modal for youtube
document.addEventListener('DOMContentLoaded', function () {
  var modal = document.getElementById('videoModal')
  var span = document.getElementsByClassName('close')[0]

  document.querySelectorAll('[data-toggle="modal"]').forEach(function (element) {
    element.onclick = function () {
      modal.style.display = 'block'
    }
  })

  span.onclick = function () {
    modal.style.display = 'none'
  }

  window.onclick = function (event) {
    if (event.target == modal) {
      modal.style.display = 'none'
    }
  }
})
