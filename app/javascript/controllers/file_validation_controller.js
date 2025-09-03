import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "error"]
  static values = { 
    maxSize: Number,
    maxFiles: Number,
    allowedTypes: Array,
    allowedExtensions: Array,
    maxWidth: Number,
    maxHeight: Number,
    minWidth: Number,
    minHeight: Number
  }

  connect() {
    // Set default values if not provided
    this.maxSizeValue = this.maxSizeValue || 5 * 1024 * 1024 // 5MB default
    this.maxFilesValue = this.maxFilesValue || 1
    this.allowedTypesValue = this.allowedTypesValue || ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
    this.allowedExtensionsValue = this.allowedExtensionsValue || ['.jpg', '.jpeg', '.png', '.gif', '.webp']
    this.maxWidthValue = this.maxWidthValue || 4000
    this.maxHeightValue = this.maxHeightValue || 4000
    this.minWidthValue = this.minWidthValue || 50
    this.minHeightValue = this.minHeightValue || 50
  }

  validate(event) {
    const files = event.target.files
    this.clearErrors()
    this.clearPreviews()

    if (files.length === 0) return

    // Check file count
    if (files.length > this.maxFilesValue) {
      this.showError(`Massa fitxers seleccionats. Màxim permès: ${this.maxFilesValue}`)
      this.clearInput()
      return
    }

    // Validate each file
    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      const fileNumber = files.length > 1 ? ` (fitxer ${i + 1})` : ''

      // Check file size
      if (file.size > this.maxSizeValue) {
        this.showError(`Fitxer massa gran${fileNumber}. Màxim: ${this.formatFileSize(this.maxSizeValue)}`)
        this.clearInput()
        return
      }

      // Check MIME type
      if (!this.allowedTypesValue.includes(file.type)) {
        this.showError(`Tipus de fitxer no permès${fileNumber}. Tipus permesos: ${this.allowedTypesValue.join(', ')}`)
        this.clearInput()
        return
      }

      // Check file extension
      const extension = this.getFileExtension(file.name)
      if (!this.allowedExtensionsValue.includes(extension)) {
        this.showError(`Extensió de fitxer no permesa${fileNumber}. Extensions permeses: ${this.allowedExtensionsValue.join(', ')}`)
        this.clearInput()
        return
      }

      // Check for suspicious file names
      if (this.isSuspiciousFileName(file.name)) {
        this.showError(`Nom de fitxer sospitós${fileNumber}. Si us plau, canvieu el nom del fitxer.`)
        this.clearInput()
        return
      }

      // For images, check dimensions and create preview
      if (file.type.startsWith('image/')) {
        this.validateImageDimensions(file, fileNumber)
        this.createImagePreview(file, i)
      }
    }
  }

  validateImageDimensions(file, fileNumber) {
    const img = new Image()
    const url = URL.createObjectURL(file)
    
    img.onload = () => {
      URL.revokeObjectURL(url)
      
      if (img.width > this.maxWidthValue || img.height > this.maxHeightValue) {
        this.showError(`Dimensions de la imatge massa grans${fileNumber}. Màxim: ${this.maxWidthValue}x${this.maxHeightValue}px`)
        this.clearInput()
        return
      }
      
      if (img.width < this.minWidthValue || img.height < this.minHeightValue) {
        this.showError(`Dimensions de la imatge massa petites${fileNumber}. Mínim: ${this.minWidthValue}x${this.minHeightValue}px`)
        this.clearInput()
        return
      }
    }
    
    img.onerror = () => {
      URL.revokeObjectURL(url)
      this.showError(`Fitxer d'imatge corrupte o no vàlid${fileNumber}`)
      this.clearInput()
    }
    
    img.src = url
  }

  createImagePreview(file, index) {
    if (!this.hasPreviewTarget) return

    const reader = new FileReader()
    reader.onload = (e) => {
      const preview = document.createElement('div')
      preview.className = 'inline-block m-2 p-2 border border-gray-300 rounded'
      preview.innerHTML = `
        <img src="${e.target.result}" alt="Preview" class="w-20 h-20 object-cover rounded">
        <p class="text-xs text-gray-600 mt-1">${file.name}</p>
        <p class="text-xs text-gray-500">${this.formatFileSize(file.size)}</p>
      `
      this.previewTarget.appendChild(preview)
    }
    reader.readAsDataURL(file)
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove('hidden')
      this.errorTarget.classList.add('text-red-600', 'text-sm', 'mt-2', 'p-2', 'bg-red-50', 'border', 'border-red-200', 'rounded')
    } else {
      // Fallback to alert if no error target
      alert(message)
    }
  }

  clearErrors() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ''
      this.errorTarget.classList.add('hidden')
    }
  }

  clearPreviews() {
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ''
    }
  }

  clearInput() {
    this.inputTarget.value = ''
    this.clearPreviews()
  }

  getFileExtension(filename) {
    return filename.toLowerCase().substring(filename.lastIndexOf('.'))
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  isSuspiciousFileName(filename) {
    const suspiciousPatterns = [
      /\.exe$/i,
      /\.bat$/i,
      /\.cmd$/i,
      /\.com$/i,
      /\.pif$/i,
      /\.scr$/i,
      /\.vbs$/i,
      /\.js$/i,
      /\.jar$/i,
      /\.php$/i,
      /\.asp$/i,
      /\.jsp$/i,
      /\.sh$/i,
      /\.py$/i,
      /\.rb$/i,
      /\.pl$/i,
      /\.(php|asp|jsp|sh|py|rb|pl)\./i, // Double extensions
      /^\./, // Hidden files
      /\s+\.(jpg|png|gif)\.exe$/i // Disguised executables
    ]
    
    return suspiciousPatterns.some(pattern => pattern.test(filename))
  }

  // Method to update validation parameters dynamically
  updateValidation(options = {}) {
    if (options.maxSize) this.maxSizeValue = options.maxSize
    if (options.maxFiles) this.maxFilesValue = options.maxFiles
    if (options.allowedTypes) this.allowedTypesValue = options.allowedTypes
    if (options.allowedExtensions) this.allowedExtensionsValue = options.allowedExtensions
    if (options.maxWidth) this.maxWidthValue = options.maxWidth
    if (options.maxHeight) this.maxHeightValue = options.maxHeight
    if (options.minWidth) this.minWidthValue = options.minWidth
    if (options.minHeight) this.minHeightValue = options.minHeight
  }
}
