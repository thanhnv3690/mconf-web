# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class InvoicesController < InheritedResources::Base
  before_filter :authenticate_user!

  before_filter :find_invoice
  authorize_resource :invoice, :through => :user, :singleton => true

  layout :determine_layout

  def determine_layout
    if [:new].include?(action_name.to_sym) or [:create].include?(action_name.to_sym)
      "no_sidebar"
    else
      "application"
    end
  end

  def find_invoice
    @invoice ||= Invoice.find_by(id: params[:id])
  end

  def show
  end
end
