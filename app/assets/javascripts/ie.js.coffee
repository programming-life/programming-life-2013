###
Hack in support for Function.name for browsers that don't support it.
 * IE, I'm looking at you.
###

if not Function.prototype.name? and Object.defineProperty? 
    Object.defineProperty( Function.prototype, 'name', 
        get: () ->
            funcNameRegex = /function\s([^(]{1,})\(/
            results = (funcNameRegex).exec @.toString()
            return if results and results.length > 1 then results[1].trim() else ""
    )