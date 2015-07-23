_                   = require 'lodash'
request             = require 'request'

BUTTON_EVENTS =
  16: '2'
  17: '3'
  18: '4'
  34: '1'

HUE_SAT_MODIFIER    = 254;
HUE_DEGREE_MODIFIER = 182.04;

class Hue
  constructor: (@username='hue-util', @ipAddress) ->

  getUri: (path) =>
    url.format
      protocol: 'http'
      hostname: @ipAddress
      pathname: path

  handleResponse: (callback=->) =>
    (error, response, body) =>
      return callback error if error?
      return callback body if response.statusCode > 400
      if _.isArray body && body[0]?.error?
        return callback body[0].error
      callback null, body

  verify: (callback=->) =>
    @getBridgeIp (error, ipAddress) =>
      return callback error if error?
      @checkHueBridge (error) =>
        return @createUser callback if error?
        callback()

  getBridgeIps: (callback=->) =>
    requestOptions =
      method: 'GET'
      uri: 'https://www.meethue.com/api/nupnp'
      json: true

    request requestOptions, @handleResponse (error, body) =>
      return callback error if error?
      callback null, _.pluck body, 'internalipaddress'

  getBridgeIp: (callback=->)=>
    return callback null, @ipAddress if @ipAddress?
    @getBridgeIps (error, ips) =>
      return callback error if error?
      @ipAddress = _.first ips
      callback null, @ipAddress

  checkHueBridge: (callback=->) =>
    requestOptions =
      method: 'GET'
      uri: @getUri "/api/#{@username}"
    request requestOptions, @handleResponse(callback)

  createUser: (callback=->) =>
    requestOptions =
      method: 'POST'
      uri: @getUri "/api"
      json: devicetype: @username

    request requestOptions, @handleResponse(callback)

  updateHue: (options={}, callback=->) =>
    @verify (error) =>
      return callback error if error?
      endpoint = 'lights'
      action = 'state'

      endpoint = 'groups' if options.useGroup
      action = 'action' if options.useGroup

      hsv = tinycolor(options.color).toHsv()
      body =
        on: options.on
        alert: options.alert
        effect: options.effect
        transitiontime: options.transitiontime

      colorDefaults =
        bri: parseInt(hsv.v * HUE_SAT_MODIFIER)
        hue: parseInt(hsv.h * HUE_DEGREE_MODIFIER)
        sat: parseInt(hsv.s * HUE_SAT_MODIFIER)
      body = _.extend colorDefaults, body if options.color

      requestOptions =
        method: 'PUT'
        uri: @getUri "/api/#{@username}/#{endpoint}/#{options.lightNumber}/#{action}"
        json: body

      request requestOptions, @handleResponse(callback)

  checkButtons: (sensorName, callback=>) =>
    @checkSensors (error, body) =>
      return callback error if error?
      state = _.findWhere(_.values(body), name: sensorName).state
      callback button: BUTTON_EVENTS[state.buttonevent], state: state

  checkSensors: (callback=->) =>
    @verify (error) =>
      return callback error if error?
      requestOptions =
        method: 'GET'
        uri: @getUrl "/api/#{@options.apiUsername}/sensors"
        json: true
      request requestOptions, @handleResponse(callback)

module.exports = Hue
