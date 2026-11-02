import torch
import torch.nn as nn
import torch.nn.functional as F
from models.quant_layer import weight_quantize_fn, act_quantization


class QuantConv2d(nn.Conv2d):
    """QuantConv2d from quant_layer.py, but the bit width (default 2) and the initial act_alpha are arguments,
    so both quantizers are built with the right bit width when the layer is created."""
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0, dilation=1, groups=1, bias=False,
                 bit=2, act_alpha=8.0):
        super(QuantConv2d, self).__init__(in_channels, out_channels, kernel_size, stride, padding, dilation, groups,
                                          bias)
        self.layer_type = 'QuantConv2d'
        self.bit = bit
        self.weight_quant = weight_quantize_fn(w_bit=self.bit)   # signed weights:      -(2^(bit-1)-1) .. 2^(bit-1)-1
        self.act_alq = act_quantization(self.bit)                # unsigned activations: 0 .. 2^bit-1
        self.act_alpha = torch.nn.Parameter(torch.tensor(float(act_alpha)))
        self.weight_q  = torch.nn.Parameter(torch.zeros([out_channels, in_channels, kernel_size, kernel_size]))

    def forward(self, x):
        weight_q = self.weight_quant(self.weight)
        self.weight_q = torch.nn.Parameter(weight_q)  # Store weight_q during the training
        x = self.act_alq(x, self.act_alpha)
        return F.conv2d(x, weight_q, self.bias, self.stride, self.padding, self.dilation, self.groups)

    def extra_repr(self):
        return super(QuantConv2d, self).extra_repr() + ', bit={}'.format(self.bit)

    def show_params(self):
        wgt_alpha = round(self.weight_quant.wgt_alpha.data.item(), 3)
        act_alpha = round(self.act_alpha.data.item(), 3)
        print('clipping threshold weight alpha: {:2f}, activation alpha: {:2f}'.format(wgt_alpha, act_alpha))
